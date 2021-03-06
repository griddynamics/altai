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


log("Start to install rabbitmq")

package "rabbitmq-server"

node["config_files"].push("/etc/rabbitmq/rabbitmq-env.conf")
template "/etc/rabbitmq/rabbitmq-env.conf" do
    source "rabbitmq-env.conf.erb"
    mode 00660
    owner "rabbitmq"
    group "root"
end

node["services"].push({
    "name"=>"rabbitmq", 
    "type"=>"amqp",
    "ip"=>node["master-ip-private"],
    "port"=>5672
})  

service "rabbitmq-server" do
    action [:restart, :enable]
end

log("Rabbitmq was succesfully installed")



