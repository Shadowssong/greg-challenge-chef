#
# Cookbook Name:: nginx-ubuntu
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


package "python-software-properties" do 
  action :install
end

execute "add nginx ppa" do 
  command "sudo -s add-apt-repository ppa:nginx/stable"
  action :run 
  not_if "apt-cache policy | grep nginx"
end

execute "update apt" do 
  command "sudo apt-get update"
  action :run
end

package "nginx" do 
  action :install
end
