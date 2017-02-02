#
# Cookbook Name:: redmine2
# Recipe:: default
#
# Copyright 2014, Anton Minin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Create a redmine OS account with the users cookbook
user node[:redmine][:user] do
  comment 'Redmine user'
  shell '/bin/bash'
  home node[:redmine][:home]
  action :create
end

# Create home directory
directory node[:redmine][:home] do
  owner node[:redmine][:user]
  group node[:redmine][:user]
  mode '0755'
end

if node[:redmine][:ruby_version] == 'system'
  bundle_command = 'bundle'
  rake_command = 'rake'
  ruby_command = 'ruby'
else
  # Install ruby with rbenv
  include_recipe 'rbenv::default'
  include_recipe 'ruby_build'

  rbenv_ruby node[:redmine][:ruby_version] do
    global true
  end

  rbenv_gem 'bundler' do
    ruby_version node[:redmine][:ruby_version]
  end

  bundle_command = "#{node[:rbenv][:root]}/shims/bundle"
  rake_command = "#{node[:rbenv][:root]}/shims/bundle exec rake"
  ruby_command = "#{node[:rbenv][:root]}/shims/ruby"
end

# Download archive with source code
bash 'install_redmine' do
  cwd node[:redmine][:home]
  user node[:redmine][:user]
  code <<-EOH
    wget http://www.redmine.org/releases/redmine-#{node[:redmine][:version]}.tar.gz;
    tar -xzf redmine-#{node[:redmine][:version]}.tar.gz
  EOH
  not_if { ::File.exist?("#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/Rakefile") }
end

link "#{node[:redmine][:home]}/redmine" do
  to "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}"
end

# Create database
case node[:redmine][:db][:type]
when 'sqlite'
  include_recipe 'redmine2::sqlite'
when 'mysql'
  include_recipe 'redmine2::mysql'
when 'postgresql'
  include_recipe 'redmine2::postgresql'
end

template "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/config/database.yml" do
  source 'database.yml.erb'
  owner node[:redmine][:user]
  variables database_server: node[:redmine][:db][:hostname]
  mode '0664'
end

# Configure email
template "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/config/configuration.yml" do
  source 'configuration.yml.erb'
  owner node[:redmine][:user]
  variables {}
  mode '0664'
end

# Configure environment.rb
template "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/config/environment.rb" do
  source 'environment.rb.erb'
  owner node[:redmine][:user]
  variables {}
  mode '0644'
end

# Configure custom gems e.g. thin
template "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/Gemfile.local" do
  source 'Gemfile.local.erb'
  owner node[:redmine][:user]
  variables {}
  mode '0664'
end

exclude_db_groups =
  case node[:redmine][:db][:type]
  when 'sqlite'
    %w(mysql postgresql)
  when 'mysql'
    %w(postgresql sqlite)
  when 'postgresql'
    %w(mysql sqlite)
  end
bundle_exclude_groups = node[:redmine][:bundle_exclude] + exclude_db_groups
bundle_install_command = "#{bundle_command} install --without #{bundle_exclude_groups.join(' ')} --path vendor/bundle"

execute bundle_install_command do
  user node[:redmine][:user]
  cwd "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}"
  not_if { ::File.exist?("#{node[:redmine][:home]}redmine-#{node[:redmine][:version]}/db/schema.rb") }
end

execute "RAILS_ENV='production' #{rake_command} db:migrate" do
  user node[:redmine][:user]
  cwd "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}"
  not_if { ::File.exist?("#{node[:redmine][:home]}redmine-#{node[:redmine][:version]}/db/schema.rb") }
end

execute "RAILS_ENV='production' #{rake_command} generate_secret_token" do
  user node[:redmine][:user]
  cwd "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}"
  not_if { ::File.exist?("#{node[:redmine][:home]}redmine-#{node[:redmine][:version]}/config/initializers/secret_token.rb") }
end

case node[:redmine][:init_style]
when 'upstart'
  template '/etc/init/redmine.conf' do
    source 'redmine-upstart.conf.erb'
    variables(
      env_vars: {
        'RAILS_ENV' => node[:redmine][:environment]
      },
      user: node[:redmine][:user],
      app_path: "#{node[:redmine][:home]}/redmine",
      ruby_command: ruby_command
    )
  end

  service 'redmine' do
    provider Chef::Provider::Service::Upstart
    supports status: true, restart: true, reload: true
    action [:start, :enable]
  end
when 'systemd'
  template '/etc/systemd/system/redmine.service' do
    source 'redmine.service.erb'
    variables(
      env_vars: {
        'RAILS_ENV' => node[:redmine][:environment]
      },
      user: node[:redmine][:user],
      app_path: "#{node[:redmine][:home]}/redmine",
      ruby_command: ruby_command
    )
  end

  service 'redmine' do
    provider Chef::Provider::Service::Systemd
    supports status: true, restart: true, reload: true
    action [:start, :enable]
  end
end

certificate_manage node[:redmine][:ssl_data_bag_name].to_s do
  cert_path node[:redmine][:ssl_cert_dir]
  owner node[:nginx][:user]
  group node[:nginx][:user]
  nginx_cert true
  create_subfolders true
  not_if { node[:redmine][:ssl_data_bag_name].nil? }
end

include_recipe 'nginx'

template "#{node[:nginx][:dir]}/sites-available/redmine" do
  source 'nginx-redmine.erb'
  mode 0777
  owner node[:nginx][:user]
  group node[:nginx][:user]
  variables(
    app_path:        "#{node[:redmine][:home]}/redmine",
    server_name:     node[:redmine][:host],
    listen_port:     node[:redmine][:listen_port],
    ssl_listen_port: node[:redmine][:ssl_listen_port],
    ssl_cert:        "#{node[:redmine][:ssl_cert_dir]}/certs/#{node[:fqdn]}.pem",
    ssl_key:         "#{node[:redmine][:ssl_cert_dir]}/private/#{node[:fqdn]}.key"
  )
end

nginx_site 'redmine' do
  enable true
end

# Configure SCM e.g. Git
