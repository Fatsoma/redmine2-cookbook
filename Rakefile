#!/usr/bin/env rake
require 'foodcritic'

FoodCritic::Rake::LintTask.new do |t|
  t.options = { :fail_tags => ['any'], :tags => ['~FC001'] }
end

begin
  require 'emeril/rake'
rescue LoadError
  puts '>>>>> Emeril gem not loaded, omitting tasks' unless ENV['CI']
end

begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
rescue LoadError
  puts '>>>>> Kitchen gem not loaded, omitting tasks' unless ENV['CI']
end

task :default => [:foodcritic]
