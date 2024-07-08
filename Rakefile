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

PRIVATE_KEY = 'spec/fixtures/pem/privatekey.pem'
CERTIFICATE = 'spec/fixtures/pem/certificate.pem'
AWS_FIXTURES = FileList['spec/fixtures/json/*.json'].exclude('**/*/invalid_signature.json')
SIGNABLE_KEYS = %w[
  Message
  MessageId
  Subject
  SubscribeURL
  Timestamp
  Token
  TopicArn
  Type
].freeze

file PRIVATE_KEY do |t|
  require 'openssl'
  key = OpenSSL::PKey::RSA.new 2048
  File.write(t.name, key.to_pem)
end

file CERTIFICATE => PRIVATE_KEY do |t|
  require 'openssl'
  key = OpenSSL::PKey::RSA.new File.read(PRIVATE_KEY)
  cert = OpenSSL::X509::Certificate.new
  cert.version = 2
  cert.serial = 2
  cert.subject = OpenSSL::X509::Name.parse '/DC=org/DC=ruby-lang/CN=Ruby certificate'
  cert.issuer = cert.subject # root CA is the issuer
  cert.public_key = key.public_key
  cert.not_before = Time.now
  cert.not_after = cert.not_before + (1 * 365 * 24 * 60 * 60) # 10 years validity
  ef = OpenSSL::X509::ExtensionFactory.new
  ef.subject_certificate = cert
  ef.issuer_certificate = cert
  cert.add_extension(ef.create_extension('keyUsage', 'digitalSignature', true))
  cert.add_extension(ef.create_extension('subjectKeyIdentifier', 'hash', false))
  cert.sign(key, OpenSSL::Digest.new('SHA256'))

  File.write(t.name, cert.to_pem)
end
task certificates: [PRIVATE_KEY, CERTIFICATE]

desc 'Sign AWS SES fixtures, must be called if fixtures are modified.'
task sign_aws_fixtures: :certificates do
  require 'openssl'
  require 'json'
  require 'base64'

  key = OpenSSL::PKey::RSA.new File.read(PRIVATE_KEY)

  AWS_FIXTURES.each do |fixture|
    data = JSON.parse File.read(fixture)
    string = canonical_string(data)
    signed_string = key.sign('SHA1', string)
    data['Signature'] = Base64.encode64(signed_string)
    File.write(fixture, JSON.pretty_generate(data))
  end
end

def canonical_string(message)
  parts = []

  SIGNABLE_KEYS.each do |key|
    value = message[key]
    parts << "#{key}\n#{value}\n" unless value.nil? || value.empty?
  end
  parts.join
end
