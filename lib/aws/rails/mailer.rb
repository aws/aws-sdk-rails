# This is for backwards compatibility after introducing support for SESv2.
# The old mailer is now replaced with the new SES (v1) mailer.
Aws::Rails::Mailer = Aws::Rails::SesMailer
