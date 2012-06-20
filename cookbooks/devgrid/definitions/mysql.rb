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

define :mysql_create_database do
  bash "create database and grant" do
    environment ( {
	'ROOT' => node["mysql-root-password"],
	'DB' => params[:name],
	#FIXME this line produce stupid error in ruby code
	#'USER' => params[:user],
	'USER' => params[:name],
	'PASSWD' => params[:password]
    })
    code <<-EOH
	mysql -uroot -p"$ROOT" -e "
	    DROP DATABASE IF EXISTS $DB;
	    CREATE DATABASE $DB;
	    GRANT ALL ON $DB.* TO '$USER'@'%' IDENTIFIED BY '$PASSWD';
	    GRANT ALL ON $DB.* TO '$USER'@'localhost' IDENTIFIED BY '$PASSWD'"
    EOH
    end
end
