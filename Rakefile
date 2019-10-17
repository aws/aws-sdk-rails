# frozen_string_literal: true

require 'rake/testtask'
require 'rubocop/rake_task'

root = File.dirname(__FILE__)

$VERSION = ENV['VERSION'] || File.read(File.join(root, 'VERSION')).strip

Dir.glob('**/*.rake').each do |task_file|
  load task_file
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end

RuboCop::RakeTask.new

task default: :test
