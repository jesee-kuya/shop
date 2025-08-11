# ApplicationHelper provides view helper methods available throughout the application
#
# This module contains utility methods that are commonly used across multiple views
# and layouts. It focuses on cart functionality and image handling to support
# the e-commerce features of the application.
#
# Key Features:
# - Product image display with fallback handling
# - Cart statistics for both authenticated and guest users
# - Consistent image handling across different view contexts
# - Safe navigation to prevent nil errors in views
module ApplicationHelper

  # Generate an image tag for a product with proper fallback handling
  # This method handles both uploaded images and missing image scenarios
  # to ensure consistent UI across the application.
  #
  # Features:
  # - Uses CarrierWave image versions (thumb, default, etc.)
  # - Provides fallback placeholder for products without images
  # - Accepts standard image_tag options for customization
  # - Maintains accessibility with proper alt text
  #
  # @param product [Product] The product to display an image for
  # @param version [Symbol] CarrierWave version to use (:thumb, :default, etc.)
  # @param options [Hash] Additional options passed to image_tag
  # @return [String] HTML image tag
  #
  # @example Basic usage
  #   <%= product_image_tag(@product) %>
  #
  # @example With specific version and CSS class
  #   <%= product_image_tag(@product, :default, class: "product-detail-image") %>
  def product_image_tag(product, version = :thumb, options = {})
    if product.image.present?
      # Product has an uploaded image, use the specified version
      image_tag(product.image_url(version), options)
    else
      # No image uploaded, show placeholder with appropriate alt text
      image_tag("placeholder.png", options.merge(alt: "No image available"))
    end
  end

  # Get the total number of items in the current user's cart
  # Works for both authenticated users and guests by checking session data
  # This method is commonly used in navigation bars and cart indicators
  #
  # Logic:
  # - Authenticated users: Use their persistent cart
  # - Guest users: Look up cart by session ID
  # - Returns 0 if no cart exists or cart is empty
  #
  # @return [Integer] Total number of items in the current cart
  #
  # @example In a navigation partial
  #   <span class="cart-count"><%= current_cart_count %></span>
  def current_cart_count
    if user_signed_in?
      # User is authenticated, use their cart with safe navigation
      current_user.cart&.total_items || 0
    else
      # Guest user, check session for cart ID and look up cart
      session[:cart_id] ? Cart.find_by(id: session[:cart_id])&.total_items || 0 : 0
    end
  end

  # Get the total price of items in the current user's cart
  # Works for both authenticated users and guests by checking session data
  # This method is commonly used for displaying cart totals in UI elements
  #
  # Logic:
  # - Authenticated users: Use their persistent cart
  # - Guest users: Look up cart by session ID
  # - Returns 0 if no cart exists or cart is empty
  #
  # @return [BigDecimal] Total price of all items in the current cart
  #
  # @example In a cart summary
  #   <span class="cart-total">$<%= current_cart_total %></span>
  def current_cart_total
    if user_signed_in?
      # User is authenticated, use their cart with safe navigation
      current_user.cart&.total_price || 0
    else
      # Guest user, check session for cart ID and look up cart
      session[:cart_id] ? Cart.find_by(id: session[:cart_id])&.total_price || 0 : 0
    end
  end
end
