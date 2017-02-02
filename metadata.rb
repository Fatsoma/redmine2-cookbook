name             'redmine2'
maintainer       'Anton Minin'
maintainer_email 'anton.a.minin@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures redmine2'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.4.2'

conflicts 'redmine'

depends 'rbenv'      # https://github.com/RiotGamesCookbooks/rbenv-cookbook
depends 'ruby_build' # https://github.com/fnichol/chef-ruby_build
depends 'nginx'
depends 'database'
depends 'postgresql'
depends 'mysql', '< 6.0' # before recipes removed
depends 'mysql-chef_gem', '< 1.0' # transitive dependency, before recipes removed
depends 'sqlite'
depends 'certificate'
depends 'iptables'

supports 'ubuntu'

attribute 'redmine',
          display_name:   'Redmine Hash',
          description:    'Hash of Redmine attributes',
          type:           'hash'

attribute 'redmine/home',
          display_name:    'Redmine Directory',
          description:     'Location for Redmine application',
          default:         '/home/redmine',
          recipes:         ['redmine2::default']

attribute 'redmine/host',
          display_name:    'Redmine Domain',
          description:     'Redmine Domain',
          default:         'redmine.example.com',
          recipes:         ['redmine2::default']

attribute 'redmine/user',
          display_name:    'Redmine User',
          description:     'Owner of redmine files',
          default:         'redmine',
          recipes:         ['redmine2::default']

attribute 'redmine/prefix',
          display_name:    'Redmine URL prefix',
          description:     'URL path prefix for Redmine application',
          default:         nil,
          recipes:         ['redmine2::default']

attribute 'redmine/ruby_version',
          display_name:    'Redmine Ruby Version',
          description:     'Version of Ruby to run Redmine',
          default:         '1.9.3-p484',
          recipes:         ['redmine2::default']

attribute 'redmine/version',
          display_name:    'Redmine version',
          description:     'Redmine version',
          default:         '2.6.0',
          recipes:         ['redmine2::default']

attribute 'redmine/bundle_exclude',
          display_name:    'Bundle exclude groups',
          description:     'Exclude groups from bundle',
          default:         %w(development test rmagick),
          recipes:         ['redmine2::default']

attribute 'redmine/listen_port',
          display_name:    'Listen port',
          description:     'Port to listen on in nginx',
          default:         80,
          recipes:         ['redmine2::default']

attribute 'redmine/create_db',
          display_name:    'Create DB on install',
          description:     'Whether to create DB',
          default:         'true',
          recipes:         ['redmine2::default']

attribute 'redmine/ssl_data_bag_name',
          display_name:    'SSL/TLS certificate data bag name',
          description:     'Data bag holding SSL/TLS certificate',
          default:         nil,
          recipes:         ['redmine2::default']

attribute 'redmine/ssl_cert_dir',
          display_name:    'SSL/TLS certificate directory',
          description:     'Directory to install SSL/TLS certificate to',
          default:         '/etc/nginx/ssl',
          recipes:         ['redmine2::default']

attribute 'redmine/ssl_listen_port',
          display_name:    'HTTPS Listen port',
          description:     'Port to listen on in nginx for HTTPS',
          default:         443,
          recipes:         ['redmine2::default']

attribute 'redmine/environment',
          display_name:    'Rails environment',
          description:     'Environment to run rails in',
          default:         'node.chef_environment',
          recipes:         ['redmine2::default']

attribute 'redmine/db',
          display_name:    'Redmine DB Hash',
          description:     'Hash of redmine database attributes',
          type:            'hash'

attribute 'redmine/db/type',
          display_name:    'Redmine DB type',
          description:     'Type of redmine database',
          choice:          %w(sqlite postgresql mysql),
          default:         'postgresql',
          recipes:         ['redmine2::default']

attribute 'redmine/db/dbname',
          display_name:    'Redmine DB name',
          description:     'Redmine DB name',
          default:         'redmine',
          recipes:         ['redmine2::default']

attribute 'redmine/db/username',
          display_name:    'Redmine DB user',
          description:     'Redmine DB user',
          default:         'redmine',
          recipes:         ['redmine2::default']

attribute 'redmine/db/hostname',
          display_name:    'Redmine DB host',
          description:     'Redmine DB host',
          default:         'localhost',
          recipes:         ['redmine2::default']

attribute 'redmine/db/password',
          display_name:    'Redmine DB password',
          description:     'Redmine DB password',
          default:         '123456',
          recipes:         ['redmine2::default']

attribute 'redmine/init_style',
          display_name:    'Redmine service init style',
          description:     'Init system to use',
          choice:          %w(upstart systemd),
          default:         'upstart',
          recipes:         ['redmine2::default']
