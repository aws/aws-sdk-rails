# frozen_string_literal: true

Rails.application.routes.draw do
  scope '/rails/action_mailbox', module: 'action_mailbox/ingresses' do
    post '/amazon/inbound_emails' => 'amazon/inbound_emails#create',
         as: :rails_amazon_inbound_emails
  end
end
