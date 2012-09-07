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


log("Start to install instance-notifier")


package "instance-notifier"

#TODO SNAPSHOT ? 
template "/etc/instance-notifier/local_settings.py" do
    source "instance-notifier/local_settings.py.erb"
    mode 00640
    owner "focus"
    group "focus"
end
template "/etc/instance-notifier/notification_active.txt" do
    source "instance-notifier/notification_active.txt.erb"
    mode 00640
    owner "focus"
    group "focus"
end
template "/etc/instance-notifier/notification_inactive.txt.erb" do
    source "instance-notifier/notification_inactive.txt.erb"
    mode 00640
    owner "focus"
    group "focus"
end


log("Start services"){level :debug}
service "instance-notifier" do
    action [:enable, :restart]
end

log("instance-notifier was succesfully installed")
