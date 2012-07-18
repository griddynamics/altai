#    Altai Private Cloud 
#    Copyright (C) GridDynamics Openstack Core Team, GridDynamics
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, either version 2.1 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU General Public License

require "rubygems"
require "uuid"


log("Start to install keystone")
node.set["mysql-keystone-password"] = UUID.new().generate()
node.set["keystone-magic-token"] = UUID.new().generate()
%w(openstack-keystone-essex python-keystoneclient-essex).each do |package_name|
    package package_name  
end
#FIXME - should be req of keystone-essex ? 
package "python-simplejson"

mysql_create_database "keystone" do
    user :keystone
    password node["mysql-keystone-password"]
end


node["config_files"].push("/etc/keystone/keystone.conf")
template "/etc/keystone/keystone.conf" do
    source "keystone/keystone.conf.erb"
    mode 00600
    owner "keystone"
    group "nobody"
end

node["config_files"].push("/etc/keystone/catalog.templates")
template "/etc/keystone/catalog.templates" do
    source "keystone/catalog.templates.erb"
    mode 00600
    owner "keystone"
    group "nobody"
end


execute "sync_keystone_database" do
    command "keystone-manage db_sync"
end

node["services"].push({
    "name"=>"keystone", 
    "type"=>"json", 
    "url"=>"http://#{node["master-ip-public"]}:5000/"
})  

service "keystone" do
    action :restart
end

log("Add admin, tenant and role")
try "Add admin tenant, user and role" do
    environment ( {
	'KCMD' => "keystone  --token=#{node["keystone-magic-token"]} --endpoint http://localhost:35357/v2.0",
	'LOGIN' => node["admin-login-name"],
	'PASSWD' => node["admin-login-password"],
	'EMAIL' => node["admin-login-email"] })
    code <<-EOH
    function get_id () { echo `$@ | awk '/ id / { print $4 }'`; }
    sleep 2
    ADMIN_ROLE=`get_id $KCMD role-create --name admin`
    if [ -z "$ADMIN_ROLE" ]
    then
	echo "Can't create admin role"
	exit 100
    fi
    echo "Admin role: $ADMIN_ROLE"
    MEMBER_ROLE=`get_id $KCMD role-create --name member`
    if [ -z "$MEMBER_ROLE" ]
    then
	echo "Can't create member role user"
	exit 100
    fi
    echo "Member role: $MEMBER_ROLE"
    TENANT=`get_id $KCMD tenant-create --name=systenant`
    if [ -z "$TENANT" ]
    then
	echo "Can't create systenant"
	exit 100
    fi
    echo "Tenant id: $TENANT"
    # will be used later in focus receipt
    echo "$TENANT" > /tmp/systenant.id
    ADMIN=`get_id $KCMD user-create --name="$LOGIN" --tenant_id="$TENANT" --pass="$PASSWD" --email="$EMAIL" --enabled true`
    echo "admin id: $ADMIN"
    $KCMD user-role-add --user="$ADMIN" --role="$ADMIN_ROLE" --tenant_id="$TENANT"
    EOH
end

log("Keystone was succesfully installed")
