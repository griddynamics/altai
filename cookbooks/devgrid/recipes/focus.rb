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


log("Start to install focus")

node.set["mysql-focus-password"] = UUID.new().generate()

package "memcached"
package "python-focus" 

mysql_create_database "focus" do
    user :focus
    password node["mysql-focus-password"]
end

#TODO check required perms
template "/etc/focus/local_settings.py" do
    source "focus/local_settings.py.erb"
    mode 00644
    owner "root"
    group "root"
end

execute "upload db" do 
    command "mysql -u focus -p#{node['mysql-focus-password']} focus < /etc/focus/invitations_dump.sql"
end

log("Start services"){level :debug}
service "memcached" do 
    action [:enable, :restart]
end
service "focus" do
    action [:enable, :restart]
end

log("focus was succesfully installed")
