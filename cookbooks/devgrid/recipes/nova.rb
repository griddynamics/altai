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


log("Start to install nova")
log("Start to install nova-openstack")

%w( openstack-nova-essex-api 
    openstack-nova-essex-network 
    openstack-nova-essex-objectstore 
    openstack-nova-essex-scheduler
    openstack-nova-essex-volume
    python-novaclient-essex
    openstack-nova-essex-consoleauth
    openstack-noVNC
    nova-networks-ext nova-fping-ext
    ntp).each do |package_name|
    package package_name 
end

mysql_create_database "nova" do
    user :nova
    password node["mysql-nova-password"]
end

mysql_create_database "dns" do
    user :dns
    password node["mysql-dns-password"]
end


node["config_files"].push("/etc/nova/nova.conf")
template "/etc/nova/nova.conf" do
    source "nova/nova.conf.erb"
    mode 00600
    owner "nova"
    group "nobody"
end

node["config_files"].push("/etc/nova/api-paste.ini")
template "/etc/nova/api-paste.ini" do
    source "nova/api-paste.ini.erb"
    mode 00600
    owner "nova"
    group "nobody"
end


execute "db sync" do
    command "nova-manage db sync"
end

%w(ntpd nova-api nova-network nova-scheduler nova-objectstore 
    nova-consoleauth nova-novncproxy).each do |service|
    service service do
	action [:enable, :restart]
    end
end

#try "set ip_forward" do
#    code <<-EOH
#    #FIXME - this doesn't work in Jenkins testbed
#    #echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/ip_forward
#    #sysctl -p
#    EOH
#end

log("nova was succesfully installed")
