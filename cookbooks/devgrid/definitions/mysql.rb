#
# Cookbook Name:: devgrid
# Recipe:: default
#
# Copyright 2012, GridDynamics
#
# All rights reserved - Do Not Redistribute
#

define :mysql_create_database do
  bash "create database and grant" do
    environment ( {
	'ROOT' => node["mysql-root-password"],
	'DB' => params[:name],
	'USER' => params[:user],
	'PASSWD' => params[:passwd]
    })
    code <<-EOH
	mysql -uroot -p"$ROOT" -e "
	    DROP DATABASE IF EXISTS $DB;
	    CREATE DATABASE $DB;
	    GRANT ALL ON $DB.* TO 'USER'@'%' IDENTIFIED BY '$PASSWD';
	    GRANT ALL ON $DB.* TO 'USER'@'localhost' IDENTIFIED BY '$PASSWD'"
    EOH
end
