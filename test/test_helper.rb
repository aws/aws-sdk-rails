require 'rails/railtie'
require 'action_mailer'
require 'aws-sdk-rails'
require 'minitest/autorun'

class TestMailer < ActionMailer::Base
  layout nil

  def deliverable(body:, from:, subject:, to:)
    mail(
      body: body,
      delivery_method: :aws_sdk,
      from: from,
      subject: subject,
      to: to
    )
  end
end
