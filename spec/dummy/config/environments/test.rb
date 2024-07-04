Rails.application.configure do
  config.active_storage.service = :test
  config.action_mailbox.ingress = :ses
  config.action_mailbox.ses.subscribed_topics = %w(
    arn:aws:sns:eu-west-1:012345678910:example-topic
    arn:aws:sns:eu-west-1:012345678910:recognized-topic
  )

  config.action_dispatch.show_exceptions = :none
end