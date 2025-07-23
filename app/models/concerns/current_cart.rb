module CurrentCart
  extend ActiveSupport::Concern

  private

  def current_cart
    if user_signed_in?
      current_user.find_or_create_cart
    else
      # For guest users, find or create cart and store in session
      if session[:cart_id]
        cart = Cart.find_by(id: session[:cart_id])
        if cart && cart.user_id.nil?
          cart
        else
          # Cart doesn't exist or belongs to a user, create new one
          create_guest_cart
        end
      else
        create_guest_cart
      end
    end
  end

  def create_guest_cart
    cart = Cart.create
    session[:cart_id] = cart.id
    cart
  end

  def merge_guest_cart_with_user_cart
    return unless session[:cart_id] && user_signed_in?

    guest_cart = Cart.find_by(id: session[:cart_id])
    return unless guest_cart && guest_cart.user_id.nil? && guest_cart.cart_items.any?

    user_cart = current_user.find_or_create_cart
    
    # Merge each item from guest cart to user cart
    guest_cart.cart_items.includes(:product).each do |guest_item|
      next unless guest_item.product # Skip if product was deleted
      
      user_cart.add_product(guest_item.product, guest_item.quantity)
    end

    # Clean up guest cart and session
    guest_cart.destroy
    session.delete(:cart_id)
    
    true
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
    # Handle any errors silently and clean up session
    session.delete(:cart_id)
    false
  end
end