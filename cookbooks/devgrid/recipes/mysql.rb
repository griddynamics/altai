#
# Cookbook Name:: devgrid
# Recipe:: default
#
# Copyright 2012, GridDynamics
#
# All rights reserved - Do Not Redistribute
#


log("Start to install mysql")

package "mysql-server" do
    action :install
end

log("Apply config with binding address"){level :debug}
template "/etc/my.cnf" do
    source "my.cnf.erb"
    mode 644
    owner "root"
    group "root"
end

log("Start mysql service"){level :debug}
service "mysqld" do
    action :start
end

log("Setup root user"){level :debug}
execute "setup_root_password" do
    command "mysqladmin -u root password '#{node["mysql-root-password"]}'"
end
log("Mysql was succesfully installed")



