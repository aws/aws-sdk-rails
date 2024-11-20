ActiveSupport::Notifications.subscribe(/[.]aws/) do |name, start, finish, id, _payload|
  Rails.logger.info "Got notification: #{name} #{start} #{finish} #{id}\n"
end