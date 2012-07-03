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


log("Start to install nova-dns")
node.set["mysql-dns-password"] = UUID.new().generate()


%w(nova-dns pdns pdns-backend-mysql).each do |pkg|
    package pkg
end

mysql_create_database "dns" do
    user :dns
    password node["mysql-dns-password"]
end

#TODO check correct perms
template "/etc/nova-dns/dns-api-paste.ini" do
    source "nova-dns/dns-api-paste.ini.erb"
    mode 00644
    owner "root"
    group "root"
end
template "/etc/pdns/pdns.conf" do
    source "nova-dns/pdns.conf.erb"
    mode 00644
    owner "root"
    group "root"
end

log("Start services"){level :debug}
%w( nova-dns pdns ).each do |service|
    service service do
        action [:enable, :restart]
	ignore_failure true
    end
end

log("nova-dns was succesfully installed")
