# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

$REPO_ROOT = File.dirname(__FILE__)
$VERSION = ENV['VERSION'] || File.read(File.join($REPO_ROOT, 'VERSION')).strip

Dir.glob('**/*.rake').each do |task_file|
  load task_file
end

RSpec::Core::RakeTask.new(:test)

RuboCop::RakeTask.new

task default: :test
task 'release:test' => :test
