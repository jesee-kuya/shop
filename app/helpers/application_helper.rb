module ApplicationHelper
  def product_image_tag(product, version = :thumb, options = {})
    if product.image.present?
      image_tag(product.image_url(version), options)
    else
      # Fallback image or placeholder
      image_tag("placeholder.png", options.merge(alt: "No image available"))
    end
  end

  def current_cart_count
    if user_signed_in?
      current_user.cart_item_count
    else
      session[:cart_id] ? Cart.find_by(id: session[:cart_id])&.total_items || 0 : 0
    end
  end

  def current_cart_total
    if user_signed_in?
      current_user.cart&.total_price || 0
    else
      session[:cart_id] ? Cart.find_by(id: session[:cart_id])&.total_price || 0 : 0
    end
  end
end
