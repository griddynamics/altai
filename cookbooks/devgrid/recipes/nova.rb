#
# Cookbook Name:: devgrid
# Recipe:: default
#
# Copyright 2012, GridDynamics
#
# All rights reserved - Do Not Redistribute
#
require "rubygems"
require "uuid"


log("Start to install nova")
node.set["mysql-nova-password"] = UUID.new().generate()

log("Start to install nova-openstack")

%w( openstack-nova-essex-api 
    openstack-nova-essex-network 
    openstack-nova-essex-objectstore 
    openstack-nova-essex-scheduler
    openstack-nova-essex-volume
    openstack-nova-essex-xvpvncproxy
    python-novaclient-essex ntp).each do |package_name|
    package package_name 
end

mysql_create_database "nova" do
    user :nova
    password node["mysql-nova-password"]
end


template "/etc/nova/nova.conf" do
    source "nova/nova.conf.erb"
    mode 00600
    owner "nova"
    group "nobody"
end

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
    nova-xvpvncproxy).each do |service|
    service service do
	action [:enable, :restart]
    end
end

log("nova was succesfully installed")
