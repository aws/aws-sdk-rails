# frozen_string_literal: true

task 'github:require-access-token' do
  unless ENV['AWS_SDK_FOR_RUBY_GH_TOKEN']
    warn("export ENV['AWS_SDK_FOR_RUBY_GH_TOKEN']")
    exit
  end
end

# This task must be defined to deploy
task 'github:access-token'

task 'github:release' do
  require 'octokit'

  gh = Octokit::Client.new(access_token: ENV['AWS_SDK_FOR_RUBY_GH_TOKEN'])

  repo = 'aws/aws-sdk-rails'
  tag_ref_sha = `git show-ref v#{$VERSION}`.split(' ').first
  tag = gh.tag(repo, tag_ref_sha)

  release = gh.create_release(
    repo, "v#{$VERSION}",
    name: 'Release v' + $VERSION + ' - ' + tag.tagger.date.strftime('%Y-%m-%d'),
    body: tag.message.lines.to_a[2..-1].join,
    prerelease: $VERSION.match('rc') ? true : false
  )

  gh.upload_asset(release.url, "aws-sdk-rails-#{$VERSION}.gem",
                  content_type: 'application/octet-stream')
end

task 'github:access_token'
