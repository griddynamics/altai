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


log("Start to configure firewall")

service "iptables" do
    action :stop
end

#TODO check correct perms
template "/etc/sysconfig/iptables" do
    source "sysconfig/iptables.erb"
    mode 00600
    owner "root"
    group "root"
end

service "iptables" do
    action :start
end

log("Firewall was succesfully configured")



