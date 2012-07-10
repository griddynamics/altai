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


log("Start to install nova-billing")
node.set["mysql-billing-password"] = UUID.new().generate()

package "nova-billing"

mysql_create_database "billing" do
    user :billing
    password node["mysql-billing-password"]
end

template "/etc/nova-billing/settings.json" do
    source "nova-billing/settings.json.erb"
    mode 00660
    owner "nova-billing"
    group "root"
end

bash "Update glance to use nova-billing" do
    cwd "/etc/glance"
    code <<-EOH
    if [ ! -f glance-api-paste.ini ]; then
	echo "Glance not installed"
	exit 100
    fi
    echo -e "\n[filter:billing]\npaste.filter_factory = nova_billing.os_glance:GlanceBillingFilter.factory" >> glance-api-paste.ini
    sed -i 's/context /context billing /' glance-api-paste.ini
    EOH
    not_if "grep 'filter:billing' /etc/glance/glance-api-paste.ini"
end

log("Start services"){level :debug}
%w( nova-billing-heart nova-billing-os-amqp).each do |service|
    service service do
        action [:enable, :restart]
	ignore_failure true
    end
end

log("nova-billing was succesfully installed")
