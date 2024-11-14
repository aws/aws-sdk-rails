options = {}
ActionMailer::Base.add_delivery_method :ses, Aws::ActionMailer::SES::Mailer, **options
ActionMailer::Base.add_delivery_method :ses_v2, Aws::ActionMailer::SESV2::Mailer, **options
