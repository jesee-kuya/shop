module ProductsHelper
  # Returns the seller's name or "Anonymous" if no user is associated
  def seller_name(product)
    # Safe navigation (&.) to avoid nil errors, and presence check to handle blank names
    product.user&.name.presence || 'Anonymous'
  end

  # Returns true if the current_user is allowed to edit/delete the product
  def can_modify?(product, current_user)
    # Ensure a user is signed in and is the owner of the product
    current_user.present? && product.user_id == current_user.id
  end
end
