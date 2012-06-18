#
# Cookbook Name:: devgrid
# Recipe:: default
#
# Copyright 2012, GridDynamics
#
# All rights reserved - Do Not Redistribute
#


log("Start to install odb")
%w( java-1.6.0-openjdk odb ).each do |odb_pkg| 
    package odb_pkg
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
#TODO odb return exit success 1 on stop if failure, but 0 on stop if
#failure - :restart ection is dangerous
log("Start odb service"){level :debug}
service "odb" do
    action :restart
    ignore_failure true
end

log("Odb was succesfully installed")



