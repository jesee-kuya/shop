# ProductsHelper provides view helper methods specific to product functionality
#
# This module contains utility methods for product-related views, focusing on
# user authorization, seller information display, and product-specific UI logic.
# These helpers promote DRY principles by centralizing common product view logic.
#
# Key Features:
# - Safe seller name display with fallback handling
# - Authorization checks for product modification rights
# - Consistent handling of user associations and permissions
module ProductsHelper

  # Get the display name for a product's seller
  # Provides a user-friendly name for the product creator with proper fallback
  # handling for edge cases like missing users or blank names.
  #
  # Fallback Logic:
  # 1. Use user's name if present and not blank
  # 2. Fall back to "Anonymous" if user doesn't exist or name is blank
  # 3. Safe navigation prevents nil errors
  #
  # @param product [Product] The product to get the seller name for
  # @return [String] The seller's display name or "Anonymous"
  #
  # @example In a product listing
  #   <p>Sold by: <%= seller_name(@product) %></p>
  #
  # @example In a product card
  #   <span class="seller">By <%= seller_name(product) %></span>
  def seller_name(product)
    # Safe navigation (&.) to avoid nil errors, and presence check to handle blank names
    # presence returns nil for blank strings, triggering the fallback
    product.user&.name.presence || 'Anonymous'
  end

  # Check if the current user can modify (edit/delete) a specific product
  # This authorization helper determines whether to show edit/delete buttons
  # and links in the UI based on ownership rules.
  #
  # Authorization Rules:
  # - User must be signed in (not nil)
  # - User must be the owner of the product (matching user_id)
  # - Returns false for all other cases (guests, different users)
  #
  # @param product [Product] The product to check modification rights for
  # @param current_user [User, nil] The currently signed-in user
  # @return [Boolean] True if user can modify the product, false otherwise
  #
  # @example In a product show view
  #   <% if can_modify?(@product, current_user) %>
  #     <%= link_to "Edit", edit_product_path(@product) %>
  #     <%= link_to "Delete", product_path(@product), method: :delete %>
  #   <% end %>
  #
  # @example In a product listing partial
  #   <% if can_modify?(product, current_user) %>
  #     <div class="product-actions">
  #       <!-- Edit and delete buttons -->
  #     </div>
  #   <% end %>
  def can_modify?(product, current_user)
    # Ensure a user is signed in and is the owner of the product
    # Both conditions must be true for modification rights
    current_user.present? && product.user_id == current_user.id
  end
end
