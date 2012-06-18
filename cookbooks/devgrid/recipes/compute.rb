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


log("Start to install nova-compute")

%w( ntp dbus openstack-nova-essex-compute ).each do |package_name|
    package package_name 
end

# not re-write nova.conf created in 'nova' receipt
template "/etc/nova/nova.conf" do
    source "nova/nova.conf.erb"
    mode 00600
    owner "nova"
    group "nobody"
    not_if do 
	File.exists?("/etc/nova/api-paste.ini")
    end
end


%w(ntpd messagebus libvirtd nova-compute).each do |service|
    service service do
	action [:enable, :restart]
    end
end

log("nova-compute was succesfully installed")
