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


log("Start to install odb")
#%w( java-1.6.0-openjdk odb ).each do |odb_pkg| 
#    package odb_pkg
#end
package "java-1.6.0-openjdk"
execute "install odb" do
    command "yum --nogpgcheck -y install odb"
end


log("Apply config with binding address"){level :debug}
#TODO check correct perms
#TODO why odb started with root permissions
node["config_files"].push("/etc/odb.conf")
template "/etc/odb.conf" do
    source "odb.conf.erb"
    mode 00644
    owner "root"
    group "root"
end

#TODO rewrite odb's start script to report $? !=0 on failure
#TODO odb return exit success 1 on stop if failure, but 0 on stop if
#TODO add db cleanup and service restart
log("Start odb service"){level :debug}
##TODO this not works - chef logging "service start" and do nothing
#service "odb" do 
#    action :start
#end
#TODO this works :) 
node["services"].push({
    "name"=>"odb", 
    "type"=>"REST json", 
    "url"=>"http://#{node["master-ip-private"]}:3536/"
})  

execute "start odb service" do 
    command "service odb start"
end


log("Odb was succesfully installed")



