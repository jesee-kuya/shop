class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :products, dependent: :destroy
  has_one :cart, dependent: :destroy

  def find_or_create_cart
    cart || create_cart
  end

  def cart_item_count
    cart&.cart_items_count || 0
  end
end
