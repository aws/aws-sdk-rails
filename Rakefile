# frozen_string_literal: true

require 'rake/testtask'
require 'rubocop/rake_task'

$REPO_ROOT = File.dirname(__FILE__)
$VERSION = ENV['VERSION'] || File.read(File.join($REPO_ROOT, 'VERSION')).strip

Dir.glob('**/*.rake').each do |task_file|
  load task_file
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.warning = false
end

RuboCop::RakeTask.new

task default: :test
task 'release:test' => :test
