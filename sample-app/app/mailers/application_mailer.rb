class ApplicationMailer < ActionMailer::Base
  default from: ENV['ACTION_MAILER_EMAIL']
  layout 'mailer'
end

