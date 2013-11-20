Description
===========

Installs and configures a rails and DB server for the Web Ops Challenge

Requirements
============

## Platforms

* Ubuntu 10.04 and higher

Cookbooks
==========

Requires:
* Nginx-ubuntu
* Ruby2.0-stable
* Postgresql

Attributes
==========

The following attributes are set based on the platform, see the
`attributes/default.rb` file for default values

* `node.hostname` - Node FQDN
* `node.application.username` - Username the rails application will run under
* `node.application.name` - Application name for NGINX and repo
* `node.application.directory` - Base directory where rails application will be deployed

Usage
=====

* recipe['challenge-rails-server']
