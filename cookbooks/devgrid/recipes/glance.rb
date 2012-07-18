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

# FIXME this receipt works if at _after_ nova - looks like unresolved deps
#	in packets
log("Start to install glance")
node.set["mysql-glance-password"] = UUID.new().generate()

package 'openstack-glance-essex'

mysql_create_database "glance" do
    user :glance
    password node["mysql-glance-password"]
end

node["config_files"].push("/etc/glance/glance-api.conf")
template "/etc/glance/glance-api.conf" do
    source "glance/glance-api.conf.erb"
    mode 00600
    owner "glance"
    group "nobody"
end
node["config_files"].push("/etc/glance/glance-api-paste.ini")
template "/etc/glance/glance-api-paste.ini" do
    source "glance/glance-api-paste.ini.erb"
    mode 00600
    owner "glance"
    group "nobody"
end

#TODO bind registry to 127.0.0.1 only
node["config_files"].push("/etc/glance/glance-registry.conf")
template "/etc/glance/glance-registry.conf" do
    source "glance/glance-registry.conf.erb"
    mode 00600
    owner "glance"
    group "nobody"
end
node["config_files"].push("/etc/glance/glance-registry-paste.ini")
template "/etc/glance/glance-registry-paste.ini" do
    source "glance/glance-registry-paste.ini.erb"
    mode 00600
    owner "glance"
    group "nobody"
end


node["services"].push({
    "name"=>"glance-api", 
    "type"=>"json", 
    "url"=>"http://#{node["master-ip-public"]}:9292/"
})  

%w(glance-api glance-registry).each do |service|
    service service do
	action :restart
    end
end

#TODO upload start images

log("glance was succesfully installed")
