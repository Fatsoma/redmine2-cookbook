require 'spec_helper'

describe user('redmine') do
  it { should exist }
end

describe user('redmine') do
  it { should have_home_directory '/home/redmine' }
end

describe command('ruby -v') do
  let(:path) { '/opt/rbenv/shims:$PATH' }
  its(:stdout) { should match(/ruby 1\.9\.3p484.*/) }
end

describe package('bundler') do
  let(:path) { '/opt/rbenv/shims:$PATH' }
  it { should be_installed.by('gem') }
end

describe file('/home/redmine/redmine-3.3.0') do
  it { should be_directory }
end

describe file('/home/redmine/redmine') do
  it { should be_linked_to '/home/redmine/redmine-3.3.0' }
end

describe process('ruby') do
  its(:args) { should match(%r{bin/rails s thin -b 127.0.0.1 -p 3000}) }
end
