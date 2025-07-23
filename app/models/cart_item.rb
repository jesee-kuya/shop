class CartItem < ApplicationRecord
  belongs_to :cart, counter_cache: true
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :product_id, uniqueness: { scope: :cart_id }

  def total_price
    quantity * product.price
  end

  def increment_quantity(amount = 1)
    self.quantity += amount
    save
  end

  def decrement_quantity(amount = 1)
    self.quantity -= amount
    if quantity <= 0
      destroy
    else
      save
    end
  end
end