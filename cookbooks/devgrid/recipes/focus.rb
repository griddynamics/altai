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


log("Start to install focus")

node.set["mysql-focus-password"] = UUID.new().generate()

package "memcached"
package "python-focus" 

mysql_create_database "focus" do
    user :focus
    password node["mysql-focus-password"]
end

#TODO check required perms
template "/etc/focus/local_settings.py" do
    source "focus/local_settings.py.erb"
    mode 00644
    owner "root"
    group "root"
end

execute "upload db" do 
    command "mysql -u focus -p#{node['mysql-focus-password']} focus < /etc/focus/invitations_dump.sql"
end

python "grant access for admin user in ODB" do 
    environment ({
	"USER"	    => node["admin-login-name"],
	"PASSWD"    => node["admin-login-password"],
	"EMAIL"	    => node["admin-login-email"],
	"IP" => node["master-ip-private"] })
    code <-EOH
from os import environ as env
import hashlib, base64, requests, json
    
m = hashlib.md5()
m.update(env["PASSWD"])
p = "{MD5}%s" % base64.standard_b64encode(m.digest())
response = requests.post(
    'http://%s:3536/v1/users' % (env["IP"]), 
    data=json.dumps(dict(login="", email=env["EMAIL"], username=env["USER"], passwordHash=p)),
    headers={'Content-Type': 'application/json'})
if response.status_code > 300 or response.status_code < 200:
    raise Exception("ODB return status code %s" % (response.status_code))
EOH
end
    



log("Start services"){level :debug}
service "memcached" do 
    action [:enable, :restart]
end
service "focus" do
    action [:enable, :restart]
end

log("focus was succesfully installed")
