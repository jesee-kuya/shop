# Cart model representing a shopping cart in the e-commerce system
#
# This model handles shopping cart functionality for both authenticated users and guests.
# It manages cart items, calculates totals, and provides methods for cart manipulation.
# The cart supports merging (used when guests log in) and maintains referential integrity.
#
# Attributes:
#   - user_id: ID of the user who owns this cart (nullable for guest carts)
#   - cart_items_count: Counter cache for the number of cart items (for performance)
#   - created_at/updated_at: Standard Rails timestamps
#
# Associations:
#   - belongs_to :user - The user who owns this cart (optional for guest carts)
#   - has_many :cart_items - Individual items in the cart
#   - has_many :products, through: :cart_items - Products in the cart
class Cart < ApplicationRecord
  # Cart can belong to a user (for authenticated users) or be anonymous (for guests)
  # Optional: true allows guest carts to exist without a user_id
  belongs_to :user, optional: true

  # Cart contains multiple cart items, each representing a product and quantity
  # When cart is deleted, all its items are also deleted
  has_many :cart_items, dependent: :destroy

  # Access products through cart_items association for convenience
  has_many :products, through: :cart_items

  # Validate the counter cache to ensure data integrity
  # cart_items_count should never be negative
  validates :cart_items_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Calculate the total price of all items in the cart
  # Multiplies each item's quantity by its product price and sums the results
  #
  # @return [BigDecimal] Total price of all cart items
  def total_price
    cart_items.sum { |item| item.quantity * item.product.price }
  end

  # Calculate the total number of individual items in the cart
  # This is different from cart_items.count as it considers quantity
  #
  # @return [Integer] Total quantity of all items in cart
  def total_items
    cart_items.sum(:quantity)
  end

  # Add a product to the cart with specified quantity
  # If product already exists in cart, increases the quantity
  # If product is new to cart, creates a new cart item
  #
  # @param product [Product] The product to add to cart
  # @param quantity [Integer] Number of items to add (default: 1)
  # @return [CartItem] The cart item that was created or updated
  def add_product(product, quantity = 1)
    current_item = cart_items.find_by(product: product)

    if current_item
      # Product already in cart, increase quantity
      current_item.quantity += quantity.to_i
      current_item.save
    else
      # New product, create cart item
      cart_items.create(product: product, quantity: quantity)
    end
  end

  # Remove a product completely from the cart
  # Deletes the cart item regardless of quantity
  #
  # @param product [Product] The product to remove from cart
  # @return [Boolean] True if item was found and destroyed, false otherwise
  def remove_product(product)
    cart_items.find_by(product: product)&.destroy
  end

  # Update the quantity of a specific product in the cart
  # If quantity is 0 or negative, removes the item entirely
  #
  # @param product [Product] The product to update
  # @param quantity [Integer] New quantity for the product
  # @return [Boolean] True if successful, false if item not found
  def update_quantity(product, quantity)
    item = cart_items.find_by(product: product)
    return false unless item

    if quantity.to_i <= 0
      # Remove item if quantity is 0 or negative
      item.destroy
    else
      # Update to new quantity
      item.update(quantity: quantity)
    end
  end

  # Decrease the quantity of a product in the cart
  # If the resulting quantity would be 0 or negative, removes the item
  #
  # @param product [Product] The product to decrement
  # @param quantity [Integer] Amount to decrease by (default: 1)
  # @return [Boolean] True if successful, false if item not found
  def decrement_product(product, quantity = 1)
    current_item = cart_items.find_by(product: product)
    return false unless current_item

    if current_item.quantity <= quantity
      # Remove item if decrement would result in 0 or negative quantity
      current_item.destroy
    else
      # Decrease quantity
      current_item.quantity -= quantity
      current_item.save
    end
  end

  # Check if the cart is empty
  # Uses the counter cache for performance
  #
  # @return [Boolean] True if cart has no items
  def empty?
    cart_items_count == 0
  end

  # Remove all items from the cart
  # Destroys all cart_items, which updates the counter cache automatically
  #
  # @return [void]
  def clear
    cart_items.destroy_all
  end

  # Merge another cart's items into this cart
  # Used when a guest user logs in and their guest cart needs to be merged
  # with their user cart. Handles duplicate products by adding quantities.
  #
  # @param other_cart [Cart] The cart to merge from
  # @return [Boolean] True if merge was successful, false if invalid cart
  def merge_with(other_cart)
    return false unless other_cart.is_a?(Cart)

    # Iterate through all items in the other cart
    other_cart.cart_items.includes(:product).each do |item|
      next unless item.product # Skip if product was deleted
      # Add each product with its quantity to this cart
      add_product(item.product, item.quantity)
    end

    true
  end
end
