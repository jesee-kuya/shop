class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :cart_items_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def total_price
    cart_items.sum { |item| item.quantity * item.product.price }
  end

  def total_items
    cart_items.sum(:quantity)
  end

  def add_product(product, quantity = 1)
    current_item = cart_items.find_by(product: product)
    
    if current_item
      current_item.quantity += quantity.to_i
      current_item.save
    else
      cart_items.create(product: product, quantity: quantity)
    end
  end

  def remove_product(product)
    cart_items.find_by(product: product)&.destroy
  end

  def update_quantity(product, quantity)
    item = cart_items.find_by(product: product)
    return false unless item

    if quantity.to_i <= 0
      item.destroy
    else
      item.update(quantity: quantity)
    end
  end

  def decrement_product(product, quantity = 1)
    current_item = cart_items.find_by(product: product)
    return false unless current_item

    if current_item.quantity <= quantity
      current_item.destroy
    else
      current_item.quantity -= quantity
      current_item.save
    end
  end

  def empty?
    cart_items_count == 0
  end

  def clear
    cart_items.destroy_all
  end
end
