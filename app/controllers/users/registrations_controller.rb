# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  include RackSessionsFix

  # POST /resource/sign_in
  # def create
  #   super
  # end

  private

  def respond_with(resource, _opts = {})
    render(json: { message: "You are logged in." }, status: :ok)
  end

  def respond_to_on_destroy
    log_out_success && return if current_user

    log_out_failure
  end

  def log_out_success
    render(json: { message: "You are logged out." }, status: :ok)
  end

  def log_out_failure
    render(json: { message: "Logout failed." }, status: :unauthorized)
  end
end
