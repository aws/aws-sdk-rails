# Add ActiveNotification instrumentation to all AWS SDK clients
Aws::Rails.instrument_sdk_operations

# use a regex to subscribe to all Aws notifications
ActiveSupport::Notifications.subscribe(/aws/) do |name, start, finish, id, payload|
 # process event - report metrics, whatever is needed.
 Rails.logger.info "Recieved an ActiveSupport::Notification for: #{name} event"
end
