#
# Cookbook Name:: challenge-rails-server
#

# Install Ruby
include_recipe 'ruby2.0-stable'
# Install Postgres
include_recipe 'postgres'
# Install Nginx
include_recipe 'nginx-ubuntu'

# Install helpful tools

packages = ['vim-nox','htop','sysstat','iftop','iotop']

packages.each do |pkg|
  package pkg do 
    action :install
  end
end

# Configure Postgres (incl create DB)

# Configure Nginx
# Main config
template "/etc/nginx/nginx.conf" do 
  source "nginx.conf.erb"
  owner "root" 
  group "root"
  mode "0644"
  notifies :reload, "service[nginx]", :immediately
end

# 
template "/etc/nginx/sites-available/#{node.application.name}" do 
  source "challenge_rails.conf.erb"
  owner "root" 
  group "root"
  mode "0644"
  notifies :reload, "service[nginx]", :immediately
end


# Configure Postgres backup script (cron?)
