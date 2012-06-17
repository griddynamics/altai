#
# Cookbook Name:: devgrid
# Recipe:: default
#
# Copyright 2012, GridDynamics
#
# All rights reserved - Do Not Redistribute
#


log("Start to install mysql")

%w( mysql-server MySQL-python ).each do |package_name|
    package package_name do 
	action :install
    end
end

log("Apply config with binding address"){level :debug}
template "/etc/my.cnf" do
    source "my.cnf.erb"
    mode 00644
    owner "root"
    group "root"
end

log("Setup root user"){level :debug}
bash "setup_root_password" do
    environment ( {'PASSWD' => node["mysql-root-password"]} )
    code <<-EOH
    service mysqld stop
    mysqld_safe --skip-grant-tables --skip-networking &
    mysql -u root -e "UPDATE mysql.user SET Password=PASSWORD('$PASSWD') WHERE User='root'"
    kill %1
    EOH
end

log("Start mysql service"){level :debug}
service "mysqld" do
    action :start
end

log("Mysql was succesfully installed")
