#
# Cookbook Name:: ruby-ubuntu
# Recipe:: default
#

require 'chef/shell_out'

ruby = "ruby-#{node[:ruby][:version]}-p#{node[:ruby][:patch]}"

# Packages required for building ruby from source
packages = ['build-essential', 'openssl', 'libreadline6', 'libreadline6-dev', 'curl', 'git-core', 'zlib1g', 'zlib1g-dev', 'libssl-dev', 'libyaml-dev', 'libsqlite3-dev', 'sqlite3', 'libxml2-dev', 'libxslt-dev', 'autoconf', 'libc6-dev', 'ncurses-dev', 'automake', 'libtool', 'bison', 'nodejs', 'subversion']

execute "update system" do 
  command "sudo apt-get update"
  action :run 
end

packages.each do |pkg|
  package pkg do 
    action :install 
  end
end

directory "/tmp/download" do 
  action :create
end

execute "download ruby" do 
  cwd "/tmp/download"
  command "wget http://cache.ruby-lang.org/pub/ruby/#{ruby}.tar.gz"
  creates "/tmp/download/#{ruby}.tar.gz"
  not_if { ::File.exists?("/tmp/download/#{ruby}.tar.gz")}
  action :run
end

execute "extract ruby" do 
  cwd "/tmp/download"
  command "tar -zxvf #{ruby}.tar.gz"
  creates "/tmp/download/#{ruby}"
  not_if { ::File.exists?("/tmp/download/#{ruby}")}
  action :run
end

execute "ruby configure" do 
  cwd "/tmp/download/#{ruby}"
  command "./configure"
  creates "/tmp/download/#{ruby}/Makefile"
  action :run 
end

execute "ruby make" do 
  cwd "/tmp/download/#{ruby}"
  command "make"
  creates "/tmp/download/#{ruby}/ruby"
  action :run 
end

execute "ruby make install" do 
  cwd "/tmp/download/#{ruby}"
  command "make install"
  creates "/usr/local/bin/ruby"
  action :run 
  notifies :run, "execute[gem update]", :immediately
end

execute "gem update" do 
  command "sudo gem update --system"
  action :nothing
end
