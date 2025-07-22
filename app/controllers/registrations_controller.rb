# This must be implemented.
# sign_up_params and account_update_params
class RegistrationsController < Devise::RegistrationsController
  # before creating a new user, allow :name in the sanitizer
  before_action :configure_sign_up_params, only: [:create]
  # before updating an existing user, allow :name in the sanitizer
  before_action :configure_account_update_params, only: [:update]

  private

  # Permit these params on sign up
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [:name, :email, :password, :password_confirmation]
    )
  end

  # Permit these params on account update
  def configure_account_update_params
    devise_parameter_sanitizer.permit(
      :account_update,
      keys: [:name, :email, :password, :password_confirmation, :current_password]
    )
  end
end