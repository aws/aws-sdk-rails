class MailerController < ApplicationController
  def send_ses_email
    TestMailer.send_ses_email.deliver_now
    render plain: 'Email sent using SES'
  end

  def send_ses_v2_email
    TestMailer.send_ses_v2_email.deliver_now
    render plain: 'Email sent using SES V2'
  end
end
