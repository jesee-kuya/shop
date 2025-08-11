# CurrentCart concern for managing shopping carts across user sessions
#
# This concern provides cart management functionality that works seamlessly
# for both authenticated users and guest users. It handles:
# - Creating and retrieving carts for different user states
# - Storing guest cart information in sessions
# - Merging guest carts with user carts upon login/registration
# - Maintaining cart persistence across browser sessions
#
# Key Features:
# - Guest users get anonymous carts stored in the database with session tracking
# - Authenticated users get persistent carts tied to their account
# - When guests log in, their cart automatically merges with their user cart
# - Robust error handling prevents cart data loss
#
# Usage:
#   Include this concern in controllers that need cart functionality:
#   class ProductsController < ApplicationController
#     include CurrentCart
#     # Now you can use current_cart method
#   end
module CurrentCart
  extend ActiveSupport::Concern

  private

  # Get the current cart for the current user/session
  # Returns different cart types based on authentication status:
  # - For authenticated users: their persistent user cart
  # - For guest users: anonymous cart stored in session
  #
  # This method ensures every user (authenticated or not) always has a cart
  # available for shopping operations.
  #
  # @return [Cart] The current cart for this user/session
  def current_cart
    if user_signed_in?
      # User is authenticated, use their persistent cart
      current_user.find_or_create_cart
    else
      # Guest user - manage cart through session
      if session[:cart_id]
        # Try to find existing guest cart
        cart = Cart.find_by(id: session[:cart_id])
        if cart && cart.user_id.nil?
          # Found valid guest cart (not assigned to any user)
          cart
        else
          # Cart doesn't exist or belongs to a user, create new guest cart
          create_guest_cart
        end
      else
        # No cart in session, create new guest cart
        create_guest_cart
      end
    end
  end

  # Create a new cart for guest users
  # Creates an anonymous cart (user_id: nil) and stores its ID in the session
  # for future retrieval. This allows guests to maintain their cart across
  # page requests without requiring authentication.
  #
  # @return [Cart] Newly created guest cart
  def create_guest_cart
    cart = Cart.create
    session[:cart_id] = cart.id
    cart
  end

  # Merge a guest user's cart with their user cart upon login/registration
  # This method is called after successful authentication to ensure no cart
  # items are lost when a guest becomes an authenticated user.
  #
  # Process:
  # 1. Find the guest cart from session
  # 2. Get or create the user's persistent cart
  # 3. Transfer all items from guest cart to user cart
  # 4. Handle duplicate products by adding quantities
  # 5. Clean up guest cart and session data
  #
  # @return [Boolean] True if merge was successful, false otherwise
  def merge_guest_cart_with_user_cart
    # Only proceed if we have a guest cart and user is signed in
    return unless session[:cart_id] && user_signed_in?

    # Find the guest cart
    guest_cart = Cart.find_by(id: session[:cart_id])
    # Only merge if guest cart exists, has no user, and contains items
    return unless guest_cart && guest_cart.user_id.nil? && guest_cart.cart_items.any?

    # Get the user's persistent cart
    user_cart = current_user.find_or_create_cart

    # Transfer each item from guest cart to user cart
    guest_cart.cart_items.includes(:product).each do |guest_item|
      next unless guest_item.product # Skip if product was deleted

      # Add product to user cart (handles quantity merging automatically)
      user_cart.add_product(guest_item.product, guest_item.quantity)
    end

    # Clean up: remove guest cart and clear session
    guest_cart.destroy
    session.delete(:cart_id)

    true
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
    # Handle any database errors gracefully
    # Clean up session to prevent future errors
    session.delete(:cart_id)
    false
  end
end