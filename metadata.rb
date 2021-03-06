name             'redmine2'
maintainer       'Anton Minin'
maintainer_email 'anton.a.minin@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures redmine2'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.5.0'

conflicts 'redmine'

depends 'rbenv'      # https://github.com/RiotGamesCookbooks/rbenv-cookbook
depends 'ruby_build' # https://github.com/fnichol/chef-ruby_build
depends 'nginx'
depends 'runit'
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

attribute 'redmine/ruby_version',
          display_name:    'Redmine Ruby Version',
          description:     'Version of Ruby to run Redmine',
          default:         '2.3.1',
          recipes:         ['redmine2::default']

attribute 'redmine/version',
          display_name:    'Redmine version',
          description:     'Redmine version',
          default:         '3.3.0',
          recipes:         ['redmine2::default']

attribute 'redmine/create_db',
          display_name:    'Create DB on install',
          description:     'Whether to create DB',
          default:         'true',
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
