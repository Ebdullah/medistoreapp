class WelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user)
    begin
      UserMailer.welcome_email(user).deliver_now
    rescue StandardError => e
      Rails.logger.error "Failed to send welcome email: #{e.message}"
      raise e
    end
  end
end
