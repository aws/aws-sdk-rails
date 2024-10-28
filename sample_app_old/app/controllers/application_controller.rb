class ApplicationController < ActionController::Base

  def test_job
    job = HelloJob.perform_later(params[:name])
    Rails.logger.info "Queued up a HelloJob: #{job}"
    render json: {job: job}
  end
end
