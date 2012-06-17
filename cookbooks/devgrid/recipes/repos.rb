#
# Cookbook Name:: devgrid
# Recipe:: default
#
# Copyright 2012, GridDynamics
#
# All rights reserved - Do Not Redistribute
#

case node["platform"]
    when "centos", "redhat", "fedora" 

        execute "add_epel_repository" do
            command "rpm -Uhv #{node[:epel][:rpm_url]}"
            not_if do
                File.exists?("/etc/yum.repos.d/epel.repo") 
            end
        end
	
	#TODO add gpg_check
        template "/etc/yum.repos.d/gd-openstack.repo" do
            source "gd-openstack.erb"
            mode 00644
            owner "root"
            group "root"
            not_if do
                File.exists?("/etc/yum.repos.d/gd-openstack.repo")
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
