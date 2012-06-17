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
#TODO check correct perms
template "/etc/odb.conf" do
    source "odb.conf.erb"
    mode 00644
    owner "root"
    group "root"
end

#TODO rewrite odb's start script to report $? !=0 on failure
log("Start odb service"){level :debug}
service "odb" do
    action :restart
end

log("Odb was succesfully installed")



