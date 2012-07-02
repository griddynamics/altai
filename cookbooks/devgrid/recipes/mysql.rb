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
try "setup_root_password" do
    environment ( {'PASSWD' => node["mysql-root-password"]} )
    code <<-EOH
    service mysqld stop
    perl -i.bak -pe 's/(\\[mysqld\\])/\\1\\nskip-grant-tables\\nskip-networking/' /etc/my.cnf
    service mysqld start
    mysql -u root -e "UPDATE mysql.user SET Password=PASSWORD('$PASSWD') WHERE User='root'"
    mv /etc/my.cnf{.bak,}
    service mysqld restart
    EOH
end

log("Mysql was succesfully installed")
