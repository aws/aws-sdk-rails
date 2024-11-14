# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rake/testtask'
require 'rubocop/rake_task'

Dir.glob('**/*.rake').each do |task_file|
  load task_file
end

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec)

# Eventually, migrate all tests back into the minitest
# runner. But use minitest-spec-rails to enable syntax.
# Currently, rails generator specs are not running.
Rake::TestTask.new('test:rails') do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.warning = false
end

task test: [:spec, 'test:rails']
task default: :test
task 'release:test' => :test
