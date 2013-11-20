#
# Cookbook Name:: challenge-rails-server
#

# Install Ruby
include_recipe 'ruby2.0-stable'

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

# Configure Nginx
# Main config
template "/etc/nginx/nginx.conf" do 
  source "nginx.conf.erb"
  owner "root" 
  group "root"
  mode "0644"
#  notifies :reload, "service[nginx]", :immediately
end

# Site config for application 
template "/etc/nginx/sites-available/#{node.application.name}" do 
  source "challenge_rails.conf.erb"
  owner "root" 
  group "root"
  mode "0644"
#  notifies :reload, "service[nginx]", :immediately
end

# Configure Postgres backup script (cron?)
directory "/opt/postgresql-backup" do 
  action :create
end

template "/opt/postgresql-backup/psql-backup.rb" do 
  source "psql-backup.rb.erb"
  owner "root" 
  group "root"
  mode "0644"
end

cron "postgresql-backup" do
  minute "0"
  hour "2"
	day "*"
  user "root"
  command %Q{ ruby /opt/postgresql-backup/psql-backup.rb }
end
