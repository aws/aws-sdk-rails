# frozen_string_literal: true

Aws.config.update(
  endpoint: ENV['AWS_SERVICE_ENDPOINT'],
)
