class ApplicationController < ActionController::Base
  include CurrentCart
  
  protect_from_forgery with: :exception
  before_action :authenticate_user!, except: [:index, :show]
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Override Devise's after sign in behavior to merge carts
  def after_sign_in_path_for(resource)
    merge_guest_cart_with_user_cart
    stored_location_for(resource) || root_path
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
