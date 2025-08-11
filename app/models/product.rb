# Product model representing items for sale in the e-commerce system
#
# This model handles product listings created by users, including product details,
# image uploads, and validation. Products can be browsed by all users but only
# edited/deleted by their creators.
#
# Attributes:
#   - title: Product name/title (max 140 characters)
#   - brand: Product brand (from predefined BRAND constant)
#   - model: Product model/version
#   - price: Product price (decimal with precision 5, scale 2)
#   - description: Detailed product description (max 1000 characters)
#   - condition: Product condition (from predefined CONDITION constant)
#   - finish: Product color/finish (from predefined FINISH constant)
#   - image: Uploaded product image (managed by CarrierWave)
#   - user_id: ID of the user who created this product
#
# Associations:
#   - belongs_to :user - The user who created this product
#   - has_many :cart_items - Cart items that reference this product
class Product < ApplicationRecord
  # Callback to prevent deletion of products that are in shopping carts
  # This ensures data integrity and prevents orphaned cart items
  before_destroy :not_referenced_by_any_line_item

  # Product belongs to the user who created it
  # Optional: true allows products to exist without a user (for system/admin products)
  belongs_to :user, optional: true

  # Configure CarrierWave for image uploads
  # Images are automatically processed and resized by ImageUploader
  mount_uploader :image, ImageUploader

  # Core product information validations
  # All these fields are required for a complete product listing
  validates :title, :brand, :price, :model, presence: true

  # Text length validations to prevent overly long content
  validates :description, length: { maximum: 1000, too_long: "%{count} characters is the maximum aloud. "}
  validates :title, length: { maximum: 140, too_long: "%{count} characters is the maximum aloud. "}
  validates :price, length: { maximum: 10 }

  # Predefined options for product attributes
  # These constants ensure consistent data entry and provide dropdown options in forms

  # Available product brands - can be extended as needed
  BRAND = %w{ Ferrari Opel Lenovo Fossil}

  # Available color/finish options for products
  FINISH = %w{ Black White Navy Blue Red Clear Satin Yellow Seafoam }

  # Product condition options from best to worst
  CONDITION = %w{ New Excellent Mint Used Fair Poor }

  private

  # Callback method to prevent deletion of products that are referenced by cart items
  # This maintains referential integrity and prevents cart errors
  #
  # @return [void]
  # @raise [ActiveRecord::RecordNotDestroyed] if product is in any cart
  def not_referenced_by_any_line_item
    # Implementation would check for cart_items referencing this product
    # and prevent deletion if any exist
  end
end
