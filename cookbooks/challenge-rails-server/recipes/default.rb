#
# Cookbook Name:: challenge-rails-server
#

# Install Ruby
include_recipe 'ruby-ubuntu'

# Install Nginx
include_recipe 'nginx-ubuntu'

# Install Postgres
package 'postgresql-9.1' do
	action :install
end

# Install Rails
execute "gem rails" do 
  command "gem install rails"
  action :run 
  not_if "gem list | grep rails"
end

# Install helpful operation tools
packages = ['vim-nox','htop','sysstat','iftop','iotop']
packages.each do |pkg|
  package pkg do 
    action :install
  end
end

# Configure Postgres (incl create DB)
# TODO
# CREATE ROLE redmine LOGIN ENCRYPTED PASSWORD 'my_password' NOINHERIT VALID UNTIL 'infinity';
# CREATE DATABASE redmine WITH ENCODING='UTF8' OWNER=redmine;

# Add application user and directories
user "#{node.application.username}" do 
  action :create
  home "#{node.application.directory}"
  shell "/bin/bash"
end

directory "#{node.application.directory}" do 
  owner "#{node.application.username}"
  group "#{node.application.username}"
  action :create
end

# Configure Nginx
# Main config
template "/etc/nginx/nginx.conf" do 
  source "nginx.conf.erb"
  owner "root" 
  group "root"
  mode "0644"
  notifies :reload, "service[nginx]", :immediately
end

# Site config for application 
template "/etc/nginx/sites-available/#{node.application.name}" do 
  source "challenge_rails.conf.erb"
  owner "root" 
  group "root"
  mode "0644"
  notifies :reload, "service[nginx]", :immediately
end

execute "symlink nginx avail" do 
  command "ln -s /etc/nginx/sites-available/#{node.application.name} /etc/nginx/sites-enabled/#{node.application.name}"
  action :run
  not_if  { ::File.exists?("/etc/nginx/sites-enabled/#{node.application.name}")}
  notifies :reload, "service[nginx]", :immediately
end

service "nginx" do
  supports :status => true, :start => true, :stop => true, :restart => true
end

# Configure Postgres backup script 
directory "/opt/postgresql-backup" do 
  action :create
end

template "/opt/postgresql-backup/psql-backup.rb" do 
  source "psql-backup.rb.erb"
  owner "root" 
  group "root"
  mode "0644"
end

# Setup cron to run backup at 2AM everyday
cron "postgresql-backup" do
  minute "0"
  hour "2"
  day "*"
  user "root"
  command %Q{ ruby /opt/postgresql-backup/psql-backup.rb }
end
