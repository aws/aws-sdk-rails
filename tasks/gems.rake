desc 'Builds the aws-sdk-rails gem'
task 'gems:build' do
  sh("rm -f *.gem")
  sh("gem build aws-sdk-rails.gemspec")
end

task 'gems:push' do
  sh("gem push aws-sdk-rails-#{$VERSION}.gem")
end
