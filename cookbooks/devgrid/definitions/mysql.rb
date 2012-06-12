#
# Cookbook Name:: devgrid
# Recipe:: default
#
# Copyright 2012, GridDynamics
#
# All rights reserved - Do Not Redistribute
#

define :mysql_add_grants_for_user do
  execute "add_mysql_grants" do
    command "mysql -uroot -p#{node["mysql-root-password"]} -e \"GRANT ALL ON #{params[:database]}.* TO '#{params[:name]}'@'%' IDENTIFIED BY '#{params[:password]}';\""
  end
end

define :mysql_create_database do
  execute "mysql_create_database" do
    command "mysql -uroot -p#{node["mysql-root-password"]} -e \"CREATE DATABASE #{params[:name]} CHARACTER SET UTF8;\""
  end
end
