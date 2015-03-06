require "bundler/gem_tasks"
require 'rake/testtask'

Dir.glob('**/*.rake').each do |task_file|
  load task_file
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = "test/**/*_test.rb"
end
