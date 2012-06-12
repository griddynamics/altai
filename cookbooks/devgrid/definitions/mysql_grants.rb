#
# Cookbook Name:: devgrid
# Recipe:: default
#
# Copyright 2012, GridDynamics
#
# All rights reserved - Do Not Redistribute
#

define :add_mysql_grants_for_user do
  execute "add_mysql_grants" do
    command "mysql -uroot -p#{node["mysql-root-password"]} 
                -e \"GRANT ALL ON #{params["database"]}.* 
                TO '#{params["user"]}'@'%' IDENTIFIED BY '#{params["password"]}';\""
  end
end
