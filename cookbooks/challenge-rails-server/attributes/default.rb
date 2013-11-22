default[:hostname] = node.fqdn
default[:application][:username] = 'challenge'
default[:application][:name] = 'redmine'
default[:application][:directory] = '/home/challenge'
default[:backup][:directory] = '/opt/postgresql-backup'
default[:database][:username] = 'redmine'
default[:database][:password] = 'my_password'
