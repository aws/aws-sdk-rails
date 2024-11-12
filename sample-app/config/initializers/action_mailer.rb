options = {}
ActionMailer::Base.add_delivery_method :ses, Aws::ActionMailer::SESMailer, **options
ActionMailer::Base.add_delivery_method :ses_v2, Aws::ActionMailer::SESV2Mailer, **options
