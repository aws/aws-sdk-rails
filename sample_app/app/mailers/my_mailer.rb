class MyMailer < ApplicationMailer
  def send_email(options={})
    @name = options[:name]
    @email = options[:email]
    @message = options[:message]
    mail(:to=>ENV['ACTION_MAILER_EMAIL'], :subject=>"Amazon SES Email")
  end
end
