# frozen_string_literal: true

task 'changelog:version' do
  # replaces "Next Release (TBD)" in the CHANGELOG with a version and date
  changelog = File.open('CHANGELOG.md', 'r', encoding: 'UTF-8', &:read)
  changelog = changelog.lines.to_a
  changelog[0] = "#{$VERSION} (#{Time.now.strftime('%Y-%m-%d')})\n"
  changelog = changelog.join
  File.open('CHANGELOG.md', 'w', encoding: 'UTF-8') { |f| f.write(changelog) }
  sh('git add CHANGELOG.md')
end

task 'changelog:next_release' do
  # inserts a "Next Release (TDB)" section at the top of the CHANGELOG
  lines = []
  lines << "Unreleased Changes\n"
  lines << "------------------\n"
  lines << "\n"
  changelog = File.open('CHANGELOG.md', 'r', encoding: 'UTF-8', &:read)
  changelog = lines.join + changelog
  File.open('CHANGELOG.md', 'w', encoding: 'UTF-8') { |f| f.write(changelog) }
  sh('git add CHANGELOG.md')
  sh("git commit -m 'Added next release section to the changelog. [ci skip]'")
end

task 'changelog:latest' do
  # Returns the contents of the most recent CHANGELOG section
  changelog = File.open('CHANGELOG.md', 'r', encoding: 'UTF-8', &:read)
  lines = []
  changelog.lines.to_a[3..-1].each do |line|
    break if line.match(/^\d+\.\d+\.\d+/)

    lines << line
  end
  puts lines[0..-2].join
end
