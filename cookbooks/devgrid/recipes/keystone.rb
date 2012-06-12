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


log("Start to install keystone")
node.set["mysql-keystone-password"] = UUID.new().generate()
node.set["keystone-magic-token"] = UUID.new().generate()

%w(openstack-keystone-essex python-keystoneclient-essex).each do |package_name|
    package package_name do 
        action :install
    end
end

mysql_create_database "keystone" do
end

mysql_add_grants_for_user "keystone" do
    database :keystone
    password node["mysql-keystone-password"]
end


template "/etc/keystone/keystone.conf" do
    source "keystone/keystone.conf.erb"
    mode 644
    owner "root"
    group "root"
end

template "/etc/keystone/catalog.templates" do
    source "keystone/catalog.templates.erb"
    mode 644
    owner "root"
    group "root"
end


execute "sync_keystone_database" do
    command "keystone-manage db_sync"
end

service "keystone" do
    action :start
end

execute "sync_keystone" do
    command "sleep 1"
end

# I've commented it because as I understand all services should be configured in catalog.template file
#log("Add services")
#
#[{:name => "nova", :type => "compute", :description => "OpenStack Compute Service"}
#{:name => "nova-volume", :type => "volume", :description => "OpenStack Nova Volume Service"}
#{:name => "glance", :type => "image", :description => "OpenStack Image Service"}
#{:name => "keystone", :type => "identity", :description => "OpenStack Identity Service"}
#{:name => "quantum", :type => "network", :description => "Openstack Network Service"}].each do |service|
#    execute "Create service #{service[:name]}" do
#        command "keystone service-create --name #{service[:name]} 
#                    --type #{service[:type]} --description '#{service[:description]}'"
#    end
#end

log("Add roles")
%w(admin member).each do |role|
    execute "Add role #{role}" do
        command "keystone --token=#{node["keystone-magic-token"]} --endpoint http://localhost:35357/v2.0 --os_username=1 --os_password=1 role-create --name=#{role}"
    end
end

log("Add admin tenant")
execute "Add admin tenant" do
    command "keystone  --token=#{node["keystone-magic-token"]} --endpoint http://localhost:35357/v2.0 --os_username=1 --os_password=1 tenant-create --name=systenant"
end

log("Add admin user")
execute "Add admin user" do
    command "keystone  --token=#{node["keystone-magic-token"]} --endpoint http://localhost:35357/v2.0 --os_username=1 --os_password=1 user-create --name='#{node["admin-login-name"]}' --tenant_id=systenant --pass='#{node["admin-login-password"]}' --email='#{node["admin-login-email"]}' --enabled true"
end
execute "Assign admin role" do
    command "keystone  --token=#{node["keystone-magic-token"]} --endpoint http://localhost:35357/v2.0 --os_username=1 --os_password=1 user-role-add --user='#{node["admin-login-name"]}' --role=admin --tenant_name=systenant"
end

log("Keystone was succesfully installed")
