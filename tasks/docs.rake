# frozen_string_literal: true

desc 'Delete the locally generated docs.' if ENV['ALL']
task 'docs:clobber' do
  rm_rf '.yardoc'
  rm_rf 'docs'
end

desc 'Generate doc files.'
task 'docs' => 'docs:clobber' do
  sh({ 'SOURCE' => '1' }, 'bundle exec yard')
end
