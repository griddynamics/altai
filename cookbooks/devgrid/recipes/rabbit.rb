#
# Cookbook Name:: devgrid
# Recipe:: default
#
# Copyright 2012, GridDynamics
#
# All rights reserved - Do Not Redistribute
#


log("Start to install rabbitmq")

package "rabbitmq-server" do
    action :install
end

service "rabbitmq-server" do
    action :start
end

log("Rabbitmq was succesfully installed")



