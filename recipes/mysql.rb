#
# Cookbook Name:: redmine2
# Recipe:: mysql
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

mysql_service node[:mysql][:service_name] do
  charset node[:mysql][:charset]
  data_dir node[:mysql][:data_dir]
  error_log node[:mysql][:error_log]
  initial_root_password node[:mysql][:server_root_password]
  mysqld_options node[:mysql][:mysqld_options]
  port node[:mysql][:port]
  run_group node[:mysql][:server_group]
  run_user node[:mysql][:server_user]
  package_version node[:mysql][:server_package_version]
  package_action node[:mysql][:server_package_action]
  action [:create, :start]
  only_if { %w(localhost 127.0.0.1).include? node[:redmine][:db][:hostname] }
end

mysql_client 'default' do
  action :create
end

if [true, 'true'].include? node[:redmine][:create_db]
  include_recipe 'database::mysql'

  connection_info = {
    host:     node[:redmine][:db][:hostname],
    username: 'root',
    password: node[:mysql][:server_root_password]
  }

  mysql_database_user node[:redmine][:db][:username] do
    connection connection_info
    password   node[:redmine][:db][:password]
    action     :create
  end

  mysql_database node[:redmine][:db][:dbname] do
    connection connection_info
    owner node[:redmine][:db][:username]
    encoding 'utf8'
    action :create
  end

  mysql_database_user node[:redmine][:db][:username] do
    connection    connection_info
    database_name node[:redmine][:db][:dbname]
    host          '%'
    privileges    [:all]
    action        :grant
  end
end
