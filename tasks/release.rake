task 'release:require-version' do
  unless ENV['VERSION']
    warn("usage: VERSION=x.y.z rake release")
    exit
  end
end

# bumps the VERSION file
task 'release:bump-version' do
  sh("echo '#{$VERSION}' > VERSION")
  sh("git add VERSION")
end

# ensures all of the required credentials are present
task 'release:check' => [
  'release:require-version',
  'github:require-access-token',
  'git:require-clean-workspace',
]

# builds release artificats
task 'release:build' => [
  'changelog:version',
  'release:bump-version',
  'git:tag',
  'gems:build'
]

# deploys release artificats
task 'release:publish' => [
  'release:require-version',
  'git:push',
  'gems:push',
  'github:release',
]

# post release tasks
task 'release:cleanup' => [
  'changelog:next_release',
]

desc "Public release, `VERSION=x.y.z rake release`"
task :release => [
  'release:check',
  'test',
  'release:build',
  'release:publish',
  'release:cleanup'
]
