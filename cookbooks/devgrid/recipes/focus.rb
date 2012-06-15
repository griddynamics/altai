#
# Cookbook Name:: devgrid
# Recipe:: default
#
# Copyright 2012, GridDynamics
#
# All rights reserved - Do Not Redistribute
#


log("Start to install focus")

node.set["mysql-focus-password"] = UUID.new().generate()

package "python-focus" do
    action :install
end

mysql_create_database "focus" do
end

mysql_add_grants_for_user "focus" do
    database :focus
    password node["mysql-focus-password"]
end

template "/etc/focus/local_settings.py" do
    source "focus/local_settings.py.erb"
    mode 644
    owner "root"
    group "root"
end

execute "upload db" do 
    command "mysql -u focus -p#{node['mysql-focus-password']} focus < /etc/focus/invitations_dump.sql"
end

log("Start services"){level :debug}
service "focus" do
    action [:enable, :start]
end

log("focus was succesfully installed")



