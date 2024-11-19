# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

Dir.glob('tasks/**/*.rake').each do |task_file|
  load task_file
end

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new

task 'release:test' => :spec
