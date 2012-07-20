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


log("Start to install nova-dns")
node.set["mysql-dns-password"] = UUID.new().generate()


%w(nova-dns pdns pdns-backend-mysql).each do |pkg|
    package pkg
end

mysql_create_database "dns" do
    user :dns
    password node["mysql-dns-password"]
end

node["config_files"].push("/etc/nova-dns/dns-api-paste.ini")
template "/etc/nova-dns/dns-api-paste.ini" do
    source "nova-dns/dns-api-paste.ini.erb"
    mode 00660
    owner "nova"
    group "root"
end
node["config_files"].push("/etc/pdns/pdns.conf")
template "/etc/pdns/pdns.conf" do
    source "nova-dns/pdns.conf.erb"
    mode 00660
    owner "root"
    group "root"
end

log("Start services"){level :debug}
node["services"].push({
    "name"=>"PowerDNS", 
    "type"=>"dns",
    "ip"=>node["master-ip-public"],
    "port"=>53
})  
node["services"].push({
    "name"=>"nova_dns", 
    "type"=>"REST json", 
    "url"=>"http://#{node["master-ip-public"]}:15353/"
})  

try "Start nova-dns, pdns services" do
    code <<-EOH
    service nova-dns restart
    service pdns restart
    EOH
end

log("nova-dns was succesfully installed")
