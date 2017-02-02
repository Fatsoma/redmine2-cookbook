# Redmine2 Cookbook

[![Build Status](https://secure.travis-ci.org/aminin/redmine2-cookbook.png?branch=master)](http://travis-ci.org/aminin/redmine2-cookbook)

Installs Redmine v2, a Ruby on Rails ticket tracking and wiki tool

## Requirements

### Platform

Tested on ubuntu 12.04, 14.04

### cookbooks

* postgresql
* [rbenv](https://github.com/RiotGamesCookbooks/rbenv-cookbook)
* [ruby_build](https://github.com/fnichol/chef-ruby_build)
* chef_nginx
* database

## Attributes

| Key                                       | Type    | Description                      | Default                               |
|-------------------------------------------|---------|----------------------------------|---------------------------------------|
| <tt>['redmine']['home']</tt>              | String  | Location for Redmine application | <tt>/home/redmine</tt>                |
| <tt>['redmine']['host']</tt>              | String  | Redmine Domain                   | <tt>redmine.example.com</tt>          |
| <tt>['redmine']['user']</tt>              | String  | Owner of redmine files           | <tt>redmine</tt>                      |
| <tt>['redmine']['prefix']</tt>            | String  | URL path prefix for redmine      | <tt>nil</tt>                          |
| <tt>['redmine']['ruby_version']</tt>      | String  | Redmine Ruby Version             | <tt>1.9.3-p484</tt>                   |
| <tt>['redmine']['version']</tt>           | String  | Redmine version                  | <tt>2.6.0</tt>                        |
| <tt>['redmine']['bundle_exclude']</tt>    | String  | Exclude groups from bundle       | <tt>%w(development test rmagick)</tt> |
| <tt>['redmine']['listen_port']</tt>       | Fixnum  | Port to listen on                | <tt>80</tt>                           |
| <tt>['redmine']['create_db']</tt>         | Bool    | Whether to create database       | <tt>true</tt>                         |
| <tt>['redmine']['ssl_data_bag_name']</tt> | String  | Data bag holding certificate     | <tt>nil</tt>                          |
| <tt>['redmine']['ssl_cert_dir']</tt>      | String  | Directory to put certificate in  | <tt>#{node['nginx']['dir']}/ssl</tt>  |
| <tt>['redmine']['ssl_listen_port']</tt>   | Fixnum  | Port to listen on for HTTPS      | <tt>443</tt>                          |
| <tt>['redmine']['environment']</tt>       | String  | Rails environment to run         | <tt>node.chef_environment</tt>        |
| <tt>['redmine']['db']['type']</tt>        | String  | Type of redmine database         | <tt>postgresql</tt>                   |
| <tt>['redmine']['db']['dbname']</tt>      | String  | Redmine DB name                  | <tt>redmine</tt>                      |
| <tt>['redmine']['db']['username']</tt>    | String  | Redmine DB user                  | <tt>redmine</tt>                      |
| <tt>['redmine']['db']['hostname']</tt>    | String  | Redmine DB host                  | <tt>localhost</tt>                    |
| <tt>['redmine']['db']['password']</tt>    | String  | Redmine DB password              | <tt>123456</tt>                       |
| <tt>['redmine']['init_style']</tt>        | String  | Init system to use for redmine service <tt>upstart</tt>

## Usage

To install via librarian-chef add to your Cheffile the following lines

```
cookbook 'rbenv', git: 'https://github.com/RiotGamesCookbooks/rbenv-cookbook'
cookbook 'redmine2', git: 'https://github.com/aminin/redmine2-cookbook'
```

and run `librarian-chef install`

Configure your role/node e.g.:

```ruby
{
    redmine: {
        host: 'redmine.dev',
        db: {
            password: '<top-secret1>'
        }
    },
    postgresql: {
        password: {
            postgres: '<top-secret2>' # Need admin access to create redmine DB
        }
    },
    run_list: %w(recipe[postgresql::server] recipe[redmine2])
}
```

## Running tests

```
bundle exec rake foodcritic
bundle exec rake kitchen:all
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License and Authors

Authors: TODO: List authors
