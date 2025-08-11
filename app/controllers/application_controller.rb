# ApplicationController serves as the base controller for the entire application
#
# This controller establishes the foundation for all other controllers by:
# - Including cart management functionality for all controllers
# - Setting up CSRF protection for security
# - Configuring authentication requirements
# - Handling Devise parameter sanitization
# - Managing cart merging during user authentication
#
# Key Features:
# - Cart functionality available to all controllers via CurrentCart concern
# - Default authentication requirement (with exceptions for public pages)
# - Automatic cart merging when users log in
# - Custom Devise parameter handling for user registration
class ApplicationController < ActionController::Base
  # Include cart management functionality in all controllers
  # This makes current_cart and related methods available throughout the app
  include CurrentCart

  # Enable CSRF protection for all actions to prevent cross-site request forgery
  # Uses exception strategy to raise an error if CSRF token is invalid
  protect_from_forgery with: :exception

  # Require user authentication for all actions by default
  # Exceptions: index and show actions are public (for browsing products)
  # Individual controllers can override this with their own before_action
  before_action :authenticate_user!, except: [:index, :show]

  # Configure additional parameters for Devise controllers
  # Only runs when processing Devise-related requests (sign up, sign in, etc.)
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Override Devise's default redirect behavior after successful sign in
  # This method is called by Devise after a user successfully logs in
  #
  # Key functionality:
  # 1. Merges any guest cart with the user's persistent cart
  # 2. Redirects to stored location or root path
  #
  # @param resource [User] The user who just signed in
  # @return [String] URL path to redirect to after sign in
  def after_sign_in_path_for(resource)
    # Merge guest cart with user cart to preserve shopping session
    merge_guest_cart_with_user_cart

    # Redirect to originally requested page or home page
    stored_location_for(resource) || root_path
  end

  private

  # Configure additional parameters that Devise should accept
  # By default, Devise only accepts email and password
  # This method allows the 'name' field for user registration and updates
  #
  # Parameters allowed:
  # - sign_up: name (in addition to email, password, password_confirmation)
  # - account_update: name (in addition to email, password, current_password)
  #
  # @return [void]
  def configure_permitted_parameters
    # Allow 'name' parameter during user registration
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])

    # Allow 'name' parameter when updating user account
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
