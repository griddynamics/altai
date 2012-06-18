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

package "nova-billing"

mysql_create_database "billing" do
    user :billing
    password node["mysql-billing-password"]
end

#TODO check correct perms
template "/etc/nova-billing/settings.json" do
    source "nova-billing/settings.json.erb"
    mode 00644
    owner "root"
    group "root"
end

log("Start services"){level :debug}
%w( nova-billing-heart nova-billing-os-amqp).each do |service|
    service service do
        action [:enable, :restart]
	ignore_failure true
    end
end

log("nova-billing was succesfully installed")
