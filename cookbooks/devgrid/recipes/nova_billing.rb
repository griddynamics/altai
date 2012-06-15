#
# Cookbook Name:: devgrid
# Recipe:: default
#
# Copyright 2012, GridDynamics
#
# All rights reserved - Do Not Redistribute
#


log("Start to install nova-billing")
node.set["mysql-billing-password"] = UUID.new().generate()

package "nova-billing" do
    action :install
end

mysql_create_database "billing" do
end

mysql_add_grants_for_user "billing" do
    database :billing
    password node["mysql-billing-password"]
end

template "/etc/nova-billing/settings.json" do
    source "nova-billing/settings.json.erb"
    mode 644
    owner "root"
    group "root"
end

log("Start services"){level :debug}
%w( nova-billing-heart nova-billing-os-amqp).each do |service|
    service service do
        action [:enable, :start]
    end
end

log("nova-billing was succesfully installed")
