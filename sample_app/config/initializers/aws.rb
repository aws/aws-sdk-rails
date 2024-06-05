# frozen_string_literal: true

if ENV['AWS_SERVICE_ENDPOINT']
  Aws.config.update(
    endpoint: ENV['AWS_SERVICE_ENDPOINT'],
  )
end
