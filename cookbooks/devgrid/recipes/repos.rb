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

case node["platform"]
    when "centos", "redhat", "fedora" 

        execute "add_epel_repository" do
            command "rpm -Uhv #{node[:epel][:rpm_url]}"
            not_if do
                File.exists?("/etc/yum.repos.d/epel.repo") 
            end
        end
	
	if ( node[:altai][:rpm_url] =~ /\.rpm$/i )
	    execute "add altai_repository" do
		command "rpm -Uhv #{node[:altai][:rpm_url]}"
		not_if do
		    File.exists?("/etc/yum.repos.d/altai.repo") 
		end
	    end
	else
	    template "/etc/yum.repos.d/altai.repo" do
		source "altai.repo.erb"
		mode 00644
		owner "root"
		group "root"
		not_if do
		    File.exists?("/etc/yum.repos.d/altai.repo") 
		end
   	    end   
	end

	execute "rebuild yum cache" do 
	    command "yum -q makecache"
	end

	ruby_block "reload-internal-yum-cache" do
	  block do
	    Chef::Provider::Package::Yum::YumCache.instance.reload
	  end
	end

	#TODO - should we update system ? 
	execute "update system" do
	    action :nothing
	    command "yum -y update"
	end
    end
