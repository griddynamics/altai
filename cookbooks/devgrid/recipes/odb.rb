#
# Cookbook Name:: devgrid
# Recipe:: default
#
# Copyright 2012, GridDynamics
#
# All rights reserved - Do Not Redistribute
#


log("Start to install odb")
package "odb" do
    action :install
end

log("Apply config with binding address"){level :debug}
template "/etc/ironcloud.conf" do
    source "ironcloud.conf.erb"
    mode 644
    owner "root"
    group "root"
end

log("Start odb service"){level :debug}
service "odb" do
    action :start
end

log("Odb was succesfully installed")



