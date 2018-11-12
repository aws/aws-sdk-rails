# In order to make legacy versions backward compatible create
# an alias that supports deprecated delivery method of `:aws_sdk` 
# so users can still use `config.action_mailer.delivery_method = :aws_sdk`
Aws::Rails::AwsSdk = Aws::Rails::SesMailer
