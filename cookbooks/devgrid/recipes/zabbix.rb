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
    MYSQL="/usr/bin/mysql -u zabbix  -p#{node['mysql-zabbix-password']} zabbix -e"
    for script in /usr/share/doc/zabbix-server-mysql-*/database/mysql/{schema,images,data}.sql; do 
	$MYSQL < $script
    done
    $MYSQL 'update hosts set status=0 where status=1'
    $MYSQL 'INSERT INTO "items" ("itemid","type","snmp_community","snmp_oid","hostid","name","key_","delay","history","trends","status","value_type","trapper_hosts","units","multiplier","delta","snmpv3_securityname","snmpv3_securitylevel","snmpv3_authpassphrase","snmpv3_privpassphrase","formula","logtimefmt","templateid","valuemapid","delay_flex","params","ipmi_sensor","data_type","authtype","username","password","publickey","privatekey","flags","filter","interfaceid","port","description","inventory_link","lifetime") values ("23700","0","","","10001","Free disk space on /","vfs.fs.size[/,free]","60","7","365","0","3","","B","0","0","","0","","","1","",NULL,NULL,"","","","0","0","","","","","2","",NULL,"","","0","0")'
    $MYSQL 'INSERT INTO "items" ("itemid","type","snmp_community","snmp_oid","hostid","name","key_","delay","history","trends","status","value_type","trapper_hosts","units","multiplier","delta","snmpv3_securityname","snmpv3_securitylevel","snmpv3_authpassphrase","snmpv3_privpassphrase","formula","logtimefmt","templateid","valuemapid","delay_flex","params","ipmi_sensor","data_type","authtype","username","password","publickey","privatekey","flags","filter","interfaceid","port","description","inventory_link","lifetime") values ("23701","0","","","10081","Free memory, in %","vm.memory.size[pfree]","60","7","365","0","3","","%","0","0","","0","","","0","",NULL,NULL,"","","","0","0","","","","","0","",NULL,"","","0","30")'
    $MYSQL 'INSERT INTO "items" ("itemid","type","snmp_community","snmp_oid","hostid","name","key_","delay","history","trends","status","value_type","trapper_hosts","units","multiplier","delta","snmpv3_securityname","snmpv3_securitylevel","snmpv3_authpassphrase","snmpv3_privpassphrase","formula","logtimefmt","templateid","valuemapid","delay_flex","params","ipmi_sensor","data_type","authtype","username","password","publickey","privatekey","flags","filter","interfaceid","port","description","inventory_link","lifetime") values ("23702","0","","","10081","Used memory, in %","vm.memory.size[pused]","60","7","365","0","3","","%","0","0","","0","","","0","",NULL,NULL,"","","","0","0","","","","","0","",NULL,"","","0","30")'
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

template "/usr/share/zabbix/.htaccess" do
    source "zabbix/web/.htaccess.erb"
    mode 00640
    owner "zabbix"
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
