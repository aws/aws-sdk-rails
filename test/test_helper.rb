# frozen_string_literal: true

require 'rails/railtie'
require 'action_mailer'
require 'aws_sdk_rails'
require 'minitest/autorun'

class TestMailer < ActionMailer::Base
  layout nil

  def deliverable(options = {})
    mail(
      body: options[:body],
      delivery_method: :aws_sdk,
      from: options[:from],
      subject: options[:subject],
      to: options[:to]
    )
  end
end
