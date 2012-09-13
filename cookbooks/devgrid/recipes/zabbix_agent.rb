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


log("Start to install zabbix-agent")


package "zabbix-agent"

ruby_block "reset group list" do
  block do
    Etc.endgrent
  end
end

template "/etc/zabbix_agent.conf" do
    source "zabbix_agent.conf.erb"
    mode 00640
    owner "root"
    group "zabbix"
end

template "/etc/zabbix_agentd.conf" do
    source "zabbix_agentd.conf.erb"
    mode 00640
    owner "root"
    group "zabbix"
end

log("Start services"){level :debug}
service "zabbix-agentd" do 
    action [:enable, :restart]
end


log("zabbix-agent was succesfully installed")
