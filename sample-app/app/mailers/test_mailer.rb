class TestMailer < ApplicationMailer
  def send_ses_email
    mail(
      to: ENV['ACTION_MAILER_EMAIL'],
      subject: 'Amazon SES Email',
      body: 'This is a test email from Amazon SES',
      delivery_method: :ses
    )
  end

  def send_ses_v2_email
    mail(
      to: ENV['ACTION_MAILER_EMAIL'],
      subject: 'Amazon SES V2 Email',
      body: 'This is a test email from Amazon SES V2',
      delivery_method: :ses_v2
    )
  end
end
