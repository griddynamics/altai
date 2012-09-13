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
    MYSQL="/usr/bin/mysql -u zabbix  -p#{node['mysql-zabbix-password']} zabbix"
    for script in /usr/share/doc/zabbix-server-mysql-*/database/mysql/{schema,images,data}.sql; do 
	$MYSQL < $script
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

try "zabbix configure" do
    environment ({
	"IP" => node["master-ip-private"] })
    code <<-EOH
	zabbix-client -s "http://${IP}:81/zabbix" -u Admin -p zabbix -k -e '[
    {
	"method": "host.delete",
	"params": [
	    {
		"hostid": "10084"
	    }
	]
    },
    {
        "method": "action.create",
        "params": {
            "name": "Register host",
            "eventsource": "2",
            "evaltype": "0",
            "status": "0",
            "esc_period": "60",
            "def_shortdata": "Auto registration: {HOST.HOST}",
            "def_longdata": "Host name: {HOST.HOST}\\r\\nHost IP: {HOST.IP}\\r\\nAgent port: {HOST.PORT}",
            "recovery_msg": "0",
            "r_shortdata": "Auto registration: {HOST.HOST}",
            "r_longdata": "Host name: {HOST.HOST}\\r\\nHost IP: {HOST.IP}\\r\\nAgent port: {HOST.PORT}",
            "conditions": [],
            "operations": [{
                "action": "create",
                "operationtype": "2",
                "esc_period": "0",
                "esc_step_from": "1",
                "esc_step_to": "1",
                "mediatypeid": "0",
                "object": "0",
                "objectid": "0",
                "shortdata": "",
                "longdata": ""
            },{
                "action": "create",
                "operationtype": "4",
                "esc_period": "0",
                "esc_step_from": "1",
                "esc_step_to": "1",
                "mediatypeid": "0",
                "opgroup": {
                    "groupid": "2"
                }
            },{
                "action": "create",
                "operationtype": "6",
                "esc_period": "0",
                "esc_step_from": "1",
                "esc_step_to": "1",
                "mediatypeid": "0",
                "optemplate": [{
                    "templateid": "10001"
                }]
            }]
        }
    },

    {
        "method": "item.create",
        "params": {
            "name": "Processor load (1 min average)",
            "key_": "system.cpu.load[,avg1]",
            "applications": ["13", "17"],
            "hostid": "10001", "type": "0", "value_type": 0, "delay": 60
        }
    },
    {
        "method": "item.create",
        "params": {
            "name": "Processor load (5 min average)",
            "key_": "system.cpu.load[,avg5]",
            "applications": ["13", "17"],
            "hostid": "10001", "type": "0", "value_type": 0, "delay": 60
        }
    },
    {
        "method": "item.create",
        "params": {
            "name": "Processor load (15 min average)",
            "key_": "system.cpu.load[,avg15]",
            "applications": ["13", "17"],
            "hostid": "10001", "type": "0", "value_type": 0, "delay": 60
        }
    },

    {
        "method": "item.create",
        "params": {
            "name": "Free disk space on /",
            "key_": "vfs.fs.size[/,free]",
            "applications": ["5"],
            "hostid": "10001", "type": "0", "value_type": 0, "delay": 60
        }
    },
    {
        "method": "item.create",
        "params": {
            "name": "Free memory, in %",
            "key_": "vm.memory.size[pfree]",
            "applications": ["15"],
            "hostid": "10001", "type": "0", "value_type": 0, "delay": 60
        }
    },
    {
        "method": "item.create",
        "params": {
            "name": "Used memory, in %",
            "key_": "vm.memory.size[pused]",
            "applications": ["15"],
            "hostid": "10001", "type": "0", "value_type": 0, "delay": 60
        }
    }
]
'
    EOH
end
	
log("zabbix was succesfully installed")
