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
node.save()

package 'openstack-glance-essex' do
    action :install
end

mysql_create_database "glance" do
end

mysql_add_grants_for_user "glance" do
    database :glance
    password node["mysql-glance-password"]
end


template "/etc/glance/glance-api.conf" do
    source "glance/glance-api.conf.erb"
    mode 644
    owner "glance"
    group "nobody"
end
template "/etc/glance/glance-api-paste.conf" do
    source "glance/glance-api-paste.conf.erb"
    mode 644
    owner "glance"
    group "nobody"
end

template "/etc/glance/glance-registry.conf" do
    source "glance/glance-registry.conf.erb"
    mode 644
    owner "glance"
    group "nobody"
end
template "/etc/glance/glance-registry-paste.ini" do
    source "glance/glance-registry-paste.ini.erb"
    mode 644
    owner "glance"
    group "nobody"
end


%w(glance-api glance-registry).each do |service|
    service service do
	action :start
    end
end

#TODO upload start images

log("glance was succesfully installed")
