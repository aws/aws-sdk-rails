# Add ActiveNotification instrumentation to all AWS SDK clients
Aws::Rails.instrument_sdk_operations

# use a regex to subscribe to all S3 notifications
ActiveSupport::Notifications.subscribe(/S3.aws/) do |name, start, finish, id, payload|
 # process event - report metrics, whatever is needed.
end
