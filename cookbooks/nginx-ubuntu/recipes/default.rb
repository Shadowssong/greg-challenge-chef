#
# Cookbook Name:: nginx-ubuntu
#

package "python-software-properties" do 
  action :install
end

execute "add nginx ppa" do 
  command "sudo -s add-apt-repository ppa:nginx/stable"
  action :run 
  notifies :run, "execute[update apt]", :immediately
  not_if "apt-cache policy | grep nginx"
end

execute "update apt" do 
  command "sudo apt-get update"
  action :nothing
end

package "nginx" do 
  action :install
end
