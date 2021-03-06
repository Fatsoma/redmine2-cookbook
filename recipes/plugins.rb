#
# Cookbook Name:: redmine2
# Recipe:: plugins
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

package 'git-core'
package 'unzip'

bundle_command = "#{node[:rbenv][:root]}/shims/bundle"
rake_command = "#{node[:rbenv][:root]}/shims/bundle exec rake"
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
  action :nothing
end

execute "RAILS_ENV='production' #{rake_command} redmine:plugins:migrate" do
  user node[:redmine][:user]
  cwd "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}"
  action :nothing
end

service 'redmine' do
  supports status: true, start: true, stop: true, restart: true
  action :nothing
end

plugins = node[:redmine][:plugins]

if !plugins.nil? && !plugins.empty?

  plugins.each do |plugin|

    case plugin[:type]
    when 'git' then
      rev = plugin[:revision] || 'master'
      git "#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/plugins/#{plugin[:name]}" do
        repository plugin[:source]
        revision rev
        action :sync
        notifies :run, "execute[#{bundle_install_command}]", :delayed
        notifies :run, "execute[RAILS_ENV='production' #{rake_command} redmine:plugins:migrate]", :delayed
        notifies :restart, 'service[redmine]', :delayed
      end

    when 'zip' then
      zipfile = File.basename(plugin[:source])
      # FC041
      bash "Deploy #{plugin[:name]}" do
        cwd '/tmp'
        code <<-EOF
          wget #{plugin[:source]}
          unzip #{zipfile}
          mv #{plugin[:name]} #{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/plugins/#{plugin[:name]}
          rm -rf #{zipfile}
        EOF
        notifies :run, "execute[#{bundle_install_command}]", :delayed
        notifies :run, "execute[RAILS_ENV='production' #{rake_command} redmine:plugins:migrate]", :delayed
        notifies :restart, 'service[redmine]', :delayed
        not_if { ::File.exist?("#{node[:redmine][:home]}/redmine-#{node[:redmine][:version]}/plugins/#{plugin[:name]}") }
      end
    end
  end
end
