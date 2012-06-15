#
# Cookbook Name:: devgrid
# Recipe:: default
#
# Copyright 2012, GridDynamics
#
# All rights reserved - Do Not Redistribute
#
require "rubygems"
require "uuid"


log("Start to install keystone")
node.set["mysql-keystone-password"] = UUID.new().generate()
node.set["keystone-magic-token"] = UUID.new().generate()
keystone_cmd = "keystone  --token=#{node["keystone-magic-token"]} --endpoint http://localhost:35357/v2.0"
%w(openstack-keystone-essex python-keystoneclient-essex).each do |package_name|
    package package_name do 
        action :install
    end
end

mysql_create_database "keystone" do
end

mysql_add_grants_for_user "keystone" do
    database :keystone
    password node["mysql-keystone-password"]
end


template "/etc/keystone/keystone.conf" do
    source "keystone/keystone.conf.erb"
    mode 644
    owner "root"
    group "root"
end

template "/etc/keystone/catalog.templates" do
    source "keystone/catalog.templates.erb"
    mode 644
    owner "root"
    group "root"
end


execute "sync_keystone_database" do
    command "keystone-manage db_sync"
end

service "keystone" do
    action :start
end

execute "sync_keystone" do
    command "sleep 2"
end

log("Add admin, tenant and role")
bash "Add admin tenant, user and role" do
    environment ( {
	'KCMD' => keystone_cmd, 
	'LOGIN' => node["admin-login-name"],
	'PASSWD' => node["admin-login-password"],
	'EMAIL' => node["admin-login-email"] })
    code <<-EOH
    function get_id () { echo `$@ | awk '/ id / { print $4 }'`; }
    ADMIN_ROLE=`get_id $KCMD role-create --name admin`
    echo "Admin role: $ADMIN_ROLE"
    MEMBER_ROLE=`get_id $KCMD role-create --name member`
    echo "Member role: $MEMBER_ROLE"
    TENANT=`get_id $KCMD tenant-create --name=systenant`
    echo "Tenant id: $TENANT"
    ADMIN=`get_id $KCMD user-create --name="$LOGIN" --tenant_id="$TENANT" --pass="$PASSWD" --email="$EMAIL" --enabled true`
    echo "admin id: $ADMIN"
    $KCMD user-role-add --user="$ADMIN" --role="$ADMIN_ROLE" --tenant_id="$TENANT"
    EOH
end

log("Keystone was succesfully installed")
