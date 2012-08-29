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


require "rubygems"
require "uuid"

log("Start to install zabbix")


%w( zabbix zabbix-web-mysql zabbix-server-mysql zabbix-notifier).each do |package_name|
    package package_name 
end


node.set["mysql-zabbix-password"] = UUID.new().generate()

mysql_create_database "zabbix" do
    user :zabbix
    password node["mysql-zabbix-password"]
end

try "upload zabbix db" do 
    code <<-EOH
    for script in /usr/share/doc/zabbix-server-mysql-*/database/mysql/{schema,images,data}.sql; do 
	mysql -u zabbix  -p#{node['mysql-zabbix-password']} zabbix < $script
    done
    EOH
end

template "/etc/zabbix_server.conf" do
    source "zabbix_server.conf.erb"
    mode 00640
    owner "root"
    group "zabbix"
end

template "/etc/zabbix/web/zabbix.conf.php" do
    source "zabbix/web/zabbix.conf.php.erb"
    mode 00750
    owner "apache"
    group "apache"
end

# apache used for zabbix API. Let's put Apache on internal ip on port 81
template "/etc/httpd/conf/httpd.conf" do 
    source "httpd/conf/httpd.conf.erb"
    mode 00644
    owner "root"
    group "root"
end



log("Start services"){level :debug}
%w( httpd zabbix-server zabbix-notifier ).each do |service|
    service service do
        action [:enable, :restart]
    end
end



log("zabbix was succesfully installed")
