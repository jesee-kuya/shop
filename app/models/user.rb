# User model representing registered users in the e-commerce system
#
# This model handles user authentication through Devise and manages the relationship
# between users and their products/shopping carts. Each user can create multiple
# product listings and has one persistent shopping cart.
#
# Attributes:
#   - email: User's email address (required, unique)
#   - encrypted_password: Devise-managed encrypted password
#   - name: User's display name
#   - reset_password_token: Token for password reset functionality
#   - remember_created_at: Timestamp for "remember me" functionality
#
# Associations:
#   - has_many :products - Products created by this user
#   - has_one :cart - User's persistent shopping cart
class User < ApplicationRecord
  # Configure Devise modules for authentication
  # - database_authenticatable: Users can sign in with email/password
  # - registerable: Users can register new accounts
  # - recoverable: Users can reset forgotten passwords
  # - rememberable: Users can be remembered across browser sessions
  # - validatable: Email and password validation
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # User can create multiple product listings
  # When user is deleted, all their products are also deleted
  has_many :products, dependent: :destroy

  # Each user has one shopping cart that persists across sessions
  # When user is deleted, their cart is also deleted
  has_one :cart, dependent: :destroy

  # Finds the user's existing cart or creates a new one if none exists
  # This ensures every user always has a cart available for shopping
  #
  # @return [Cart] The user's cart (existing or newly created)
  def find_or_create_cart
    cart || create_cart
  end

  # Returns the total number of items in the user's cart
  # Uses the counter cache for performance and handles nil cart gracefully
  #
  # @return [Integer] Number of items in cart, 0 if no cart exists
  def cart_item_count
    cart&.cart_items_count || 0
  end
end
