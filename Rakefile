# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

$REPO_ROOT = File.dirname(__FILE__)
$VERSION = ENV['VERSION'] || File.read(File.join($REPO_ROOT, 'VERSION')).strip

Dir.glob('**/*.rake').each do |task_file|
  load task_file
end

RuboCop::RakeTask.new

task default: :spec
task 'release:test' => :spec
