#
# Cookbook Name:: devgrid
# Recipe:: default
#
# Copyright 2012, GridDynamics
#
# All rights reserved - Do Not Redistribute
#


log("Start to install mysql")

%w(mysql-server mysql).each do |package_name|
    package package_name do
        action :install
        options "--y"
    end
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



