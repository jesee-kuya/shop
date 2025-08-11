# CartItem model representing individual items within a shopping cart
#
# This is a join model between Cart and Product that also stores quantity information.
# Each cart item represents a specific product in a cart with a given quantity.
# The model ensures data integrity and provides methods for quantity manipulation.
#
# Attributes:
#   - cart_id: ID of the cart this item belongs to
#   - product_id: ID of the product this item represents
#   - quantity: Number of this product in the cart (must be > 0)
#   - created_at/updated_at: Standard Rails timestamps
#
# Associations:
#   - belongs_to :cart - The cart containing this item
#   - belongs_to :product - The product this item represents
#
# Constraints:
#   - Each product can only appear once per cart (enforced by unique constraint)
#   - Quantity must always be positive (items with 0 quantity are deleted)
class CartItem < ApplicationRecord
  # Cart item belongs to a specific cart
  # counter_cache: true automatically updates cart.cart_items_count when items are added/removed
  belongs_to :cart, counter_cache: true

  # Cart item represents a specific product
  belongs_to :product

  # Quantity must be present and greater than 0
  # Items with 0 or negative quantity should be deleted instead
  validates :quantity, presence: true, numericality: { greater_than: 0 }

  # Ensure each product appears only once per cart
  # This prevents duplicate entries and maintains data integrity
  validates :product_id, uniqueness: { scope: :cart_id }

  # Calculate the total price for this cart item
  # Multiplies the quantity by the product's unit price
  #
  # @return [BigDecimal] Total price for this cart item (quantity × unit price)
  def total_price
    quantity * product.price
  end

  # Increase the quantity of this cart item
  # Saves the record after updating the quantity
  #
  # @param amount [Integer] Amount to increase quantity by (default: 1)
  # @return [Boolean] True if save was successful
  def increment_quantity(amount = 1)
    self.quantity += amount
    save
  end

  # Decrease the quantity of this cart item
  # If the resulting quantity would be 0 or negative, destroys the item instead
  # This maintains the constraint that quantity must always be positive
  #
  # @param amount [Integer] Amount to decrease quantity by (default: 1)
  # @return [Boolean] True if save/destroy was successful
  def decrement_quantity(amount = 1)
    self.quantity -= amount
    if quantity <= 0
      # Remove item entirely if quantity becomes 0 or negative
      destroy
    else
      # Save the updated quantity
      save
    end
  end
end