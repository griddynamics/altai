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

require "rubygems"
require "uuid"


log("Start to install nova-compute")

#FIXME without kernel won't work guestfs
%w( ntp dbus openstack-nova-essex-compute kernel ).each do |package_name|
    package package_name 
end

# not re-write nova.conf created in 'nova' receipt
template "/etc/nova/nova.conf" do
    source "nova/nova.conf.erb"
    mode 00600
    owner "nova"
    group "nobody"
end


%w(ntpd messagebus libvirtd nova-compute).each do |service|
    service service do
	action [:enable, :restart]
    end
end

log("nova-compute was succesfully installed")
