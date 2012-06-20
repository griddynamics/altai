#    Altai Private Cloud 
#    Copyright (C) GridDynamics Openstack Core Team, GridDynamics
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Lesser General Public License as published by
#    the Free Software Foundation, either version 2.1 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Lesser General Public License for more details.
#
#    You should have received a copy of the GNU General Public License


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



