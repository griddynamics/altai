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


log("Start to install glance")
node.set["mysql-glance-password"] = UUID.new().generate()

package 'openstack-glance-essex'

mysql_create_database "glance" do
    user :glance
    password node["mysql-glance-password"]
end


template "/etc/glance/glance-api.conf" do
    source "glance/glance-api.conf.erb"
    mode 00600
    owner "glance"
    group "nobody"
end
template "/etc/glance/glance-api-paste.ini" do
    source "glance/glance-api-paste.ini.erb"
    mode 00600
    owner "glance"
    group "nobody"
end

template "/etc/glance/glance-registry.conf" do
    source "glance/glance-registry.conf.erb"
    mode 00600
    owner "glance"
    group "nobody"
end
template "/etc/glance/glance-registry-paste.ini" do
    source "glance/glance-registry-paste.ini.erb"
    mode 00600
    owner "glance"
    group "nobody"
end


%w(glance-api glance-registry).each do |service|
    service service do
	action :restart
    end
end

#TODO upload start images

log("glance was succesfully installed")
