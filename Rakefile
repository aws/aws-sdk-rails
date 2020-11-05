# frozen_string_literal: true

require 'rubocop/rake_task'

$REPO_ROOT = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join($REPO_ROOT, 'lib'))
$VERSION = ENV['VERSION'] || File.read(File.join($REPO_ROOT, 'VERSION')).strip

Dir.glob('**/*.rake').each do |task_file|
  load task_file
end


desc 'Runs unit tests'
task 'test' => ['test:unit']

task default: :test
