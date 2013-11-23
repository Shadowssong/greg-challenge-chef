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

# Install some required packages and helpful operation tools
packages = ['libmagickwand-dev', 'libpq-dev', 'vim-nox','htop','sysstat','iftop','iotop']

packages.each do |pkg|
  package pkg do
    action :install
  end
end

# Configure Postgres
execute "create postgres user" do
  command "sudo -u postgres psql postgres -c \"CREATE ROLE redmine LOGIN ENCRYPTED PASSWORD '#{node.database.password}' NOINHERIT VALID UNTIL 'infinity';\""
  action :run
  not_if "sudo -u postgres psql postgres -c \"SELECT usename FROM pg_user WHERE usename = 'redmine';\" | grep redmine"
end

execute "create redmine db" do
  command "sudo -u postgres psql postgres -c \"CREATE DATABASE redmine WITH OWNER=redmine TEMPLATE=template0 ENCODING='UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8';\""
  action :run
  not_if "sudo -u postgres psql postgres -c \"SELECT datname FROM pg_database WHERE datname = 'redmine';\" | grep redmine"
end

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

directory "#{node.application.directory}/.ssh" do
  owner "#{node.application.username}"
  group "#{node.application.username}"
  action :create
end

template "#{node.application.directory}/.ssh/authorized_keys" do
  source "authorized_keys.erb"
  owner "#{node.application.username}"
  group "#{node.application.username}"
  mode "0600"
end

template "#{node.application.directory}/.pgpass" do
  source "pgpass.erb"
  owner "#{node.application.username}"
  group "#{node.application.username}"
  mode "0600"
end

# Increase max file descriptors for nginx
template "/etc/security/limits.d/nginx.conf" do
  source "nginx-limits.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :run, "execute[edit_pamd]", :immediately
end

execute "edit_pamd" do
  command "echo 'session required pam_limits.so # added' >> /etc/pam.d/su"
  action :nothing
  not_if  "grep 'session required pam_limits.so # added' /etc/pamd./su"
end

# Configure Nginx
# Main config
template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[nginx]", :immediately
end

# Site config for application
template "/etc/nginx/sites-available/#{node.application.name}" do
  source "challenge_rails.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[nginx]", :immediately
end

execute "symlink nginx avail" do
  command "ln -s /etc/nginx/sites-available/#{node.application.name} /etc/nginx/sites-enabled/#{node.application.name}"
  action :run
  not_if  { ::File.exists?("/etc/nginx/sites-enabled/#{node.application.name}")}
  notifies :restart, "service[nginx]", :immediately
end

service "nginx" do
  supports :status => true, :start => true, :stop => true, :restart => true
end

# Configure Postgres backup script
directory "#{node.backup.directory}" do
  action :create
end

template "#{node.backup.directory}/psql-backup.rb" do
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
  command %Q{ ruby #{node.backup.directory}/psql-backup.rb >> #{node.backup.directory}/psql-backup.log }
end
