# CartsController manages shopping cart operations for the e-commerce system
#
# This controller handles all cart-related functionality including:
# - Displaying cart contents with all items and totals
# - Adding products to the cart with specified quantities
# - Removing individual products from the cart
# - Emptying the entire cart
# - Supporting both HTML and JSON responses for AJAX operations
#
# Key Features:
# - Works seamlessly with both authenticated users and guests
# - Comprehensive error handling for missing products
# - Real-time cart updates with JSON responses for dynamic UI
# - Automatic cart management through CurrentCart concern
# - Proper redirect handling to maintain user experience
#
# Authentication:
# - No authentication required (inherits from ApplicationController exceptions)
# - Cart operations work for both guests and authenticated users
# - Guest carts are managed through session storage
class CartsController < ApplicationController
  # Set up the current cart for all actions
  # Uses CurrentCart concern to handle both user and guest carts
  before_action :set_cart

  # Load the product for actions that need it (add_item, remove_item)
  # This ensures the product exists before attempting cart operations
  before_action :set_product, only: [:add_item, :remove_item]

  # GET /cart
  # Display the current cart with all items and calculated totals
  # Shows cart items with product details, quantities, and prices
  # Accessible to all users (guests and authenticated)
  #
  # @return [void] Renders cart show template with cart items
  def show
    # Load cart items with associated products to avoid N+1 queries
    # This provides all necessary data for displaying cart contents
    @cart_items = @cart.cart_items.includes(:product)
  end

  # POST /cart/add/:product_id
  # Add a product to the cart with specified quantity
  # Supports both HTML form submissions and AJAX requests
  # Handles quantity parameter with default value of 1
  #
  # Success responses:
  # - HTML: Redirects back with success message
  # - JSON: Returns cart statistics and success status
  #
  # Error handling:
  # - Catches product not found errors
  # - Provides appropriate error messages for both formats
  #
  # @return [void] Redirects or renders JSON based on request format
  def add_item
    # Extract quantity from parameters, default to 1 if not provided
    quantity = params[:quantity]&.to_i || 1

    # Add the product to the cart using the cart model's business logic
    @cart.add_product(@product, quantity)

    respond_to do |format|
      format.html {
        # HTML response: show success message and redirect back
        flash[:notice] = "Added to your cart"
        redirect_back(fallback_location: cart_path)
      }
      format.json {
        # JSON response: provide cart statistics for dynamic UI updates
        render json: {
          status: 'success',
          cart_count: @cart.total_items,
          cart_total: @cart.total_price,
          message: 'Item added to cart'
        }
      }
    end
  rescue ActiveRecord::RecordNotFound
    # Handle case where product doesn't exist
    respond_to do |format|
      format.html {
        flash[:alert] = "Product not found"
        redirect_to products_path
      }
      format.json { render json: { status: 'error', message: 'Product not found' } }
    end
  end

  # DELETE /cart/remove/:product_id
  # Remove a product completely from the cart
  # Removes the entire cart item regardless of quantity
  # Supports both HTML and JSON responses for flexibility
  #
  # Success responses:
  # - HTML: Redirects back with success message
  # - JSON: Returns updated cart statistics
  #
  # Error handling:
  # - Catches product not found errors
  # - Provides appropriate error messages for both formats
  #
  # @return [void] Redirects or renders JSON based on request format
  def remove_item
    # Remove the product from cart using cart model's business logic
    @cart.remove_product(@product)

    respond_to do |format|
      format.html {
        # HTML response: show success message and redirect back
        flash[:notice] = "Removed from your cart"
        redirect_back(fallback_location: cart_path)
      }
      format.json {
        # JSON response: provide updated cart statistics
        render json: {
          status: 'success',
          cart_count: @cart.total_items,
          cart_total: @cart.total_price,
          message: 'Item removed from cart'
        }
      }
    end
  rescue ActiveRecord::RecordNotFound
    # Handle case where product doesn't exist or isn't in cart
    respond_to do |format|
      format.html {
        flash[:alert] = "Product not found in cart"
        redirect_to cart_path
      }
      format.json { render json: { status: 'error', message: 'Product not found in cart' } }
    end
  end

  # DELETE /cart/empty
  # Remove all items from the cart
  # Clears the entire cart contents while preserving the cart itself
  # Useful for "Clear Cart" functionality
  #
  # Success responses:
  # - HTML: Redirects to cart with success message
  # - JSON: Returns empty cart statistics
  #
  # @return [void] Redirects or renders JSON based on request format
  def empty
    # Clear all items from the cart using cart model's business logic
    @cart.clear

    respond_to do |format|
      format.html {
        # HTML response: show success message and redirect to cart
        flash[:notice] = "Cart has been emptied"
        redirect_to cart_path
      }
      format.json {
        # JSON response: provide empty cart statistics
        render json: {
          status: 'success',
          cart_count: 0,
          cart_total: 0,
          message: 'Cart emptied'
        }
      }
    end
  end

  private

  # Set the current cart for all actions
  # Uses the CurrentCart concern to get the appropriate cart
  # (user cart for authenticated users, guest cart for anonymous users)
  #
  # @return [void] Sets @cart instance variable
  def set_cart
    @cart = current_cart
  end

  # Load the product for cart operations
  # Used by before_action for add_item and remove_item actions
  # Raises ActiveRecord::RecordNotFound if product doesn't exist
  #
  # @return [void] Sets @product instance variable
  def set_product
    @product = Product.find(params[:product_id])
  end
end
