#
# Cookbook Name:: devgrid
# Recipe:: default
#
# Copyright 2012, GridDynamics
#
# All rights reserved - Do Not Redistribute
#


log("Start to install rabbitmq")

package "rabbitmq-server"

#TODO check correct perms
template "/etc/rabbitmq/rabbitmq-env.conf" do
    source "rabbitmq-env.conf.erb"
    mode 00644
    owner "root"
    group "root"
end

service "rabbitmq-server" do
    action :restart
end

log("Rabbitmq was succesfully installed")



