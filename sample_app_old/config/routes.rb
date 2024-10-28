Rails.application.routes.draw do
  # for SES ActionMailer
  get 'email/index'
  post '/send_email', to: 'email#send_email', as: 'send_email'

  # for ActiveStorage
  resources :users

  # for SQS ActiveJob
  get '/test-job', to: 'application#test_job'
end
