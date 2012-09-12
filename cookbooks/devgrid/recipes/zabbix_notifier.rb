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


log("Start to install zabbix-notifier")


package "zabbix-notifier"

try "upload zabbix-notifier db" do 
    code <<-EOH
    zabbix-notifier --sync-db
    DB_NOTIFIER=/var/lib/zabbix-notifier/zabbix-notifier.sqlite
    sqlite3 "$DB_NOTIFIER" < /usr/share/zabbix-notifier/data.sql
    chown focus:focus "$DB_NOTIFIER"
    chown -R focus:focus "/var/log/zabbix-notifier/"
    EOH
end

template "/etc/zabbix-notifier/local_settings.py" do
    source "zabbix-notifier/local_settings.py.erb"
    mode 00640
    owner "focus"
    group "root"
end



log("Start services"){level :debug}
%w( zabbix-notifier ).each do |service|
    service service do
        action [:enable, :restart]
    end
end

log("zabbix-notifier was succesfully installed")
