class EmailController < ApplicationController
  def index
  end

  def send_email
    MyMailer.send_email(name: params[:name], phone: params[:phone], email: params[:email], message: params[:message]).deliver
    redirect_to email_index_url, notice: "Email sent!"
  end
end
