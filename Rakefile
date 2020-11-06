# frozen_string_literal: true

require 'rubocop/rake_task'

$REPO_ROOT = File.dirname(__FILE__)
$VERSION = ENV['VERSION'] || File.read(File.join($REPO_ROOT, 'VERSION')).strip

Dir.glob('**/*.rake').each do |task_file|
  load task_file
end


desc 'Runs unit tests'
task 'test' => ['test:unit']

RuboCop::RakeTask.new

task default: :test
