# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

$REPO_ROOT = File.dirname(__FILE__)
$VERSION = ENV['VERSION'] || File.read(File.join($REPO_ROOT, 'VERSION')).strip

Dir.glob('**/*.rake').each do |task_file|
  load task_file
end

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec)

task :db_migrate do
  ENV['RAILS_ENV'] = 'test'
  Dir.chdir('spec/dummy') do
    `rake db:migrate`
  end
end

task test: %i[db_migrate spec]
task default: :test
task 'release:test' => :test
