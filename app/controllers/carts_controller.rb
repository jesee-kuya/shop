class CartsController < ApplicationController
  before_action :set_cart
  before_action :set_product, only: [:add_item, :remove_item]

  def show
    @cart_items = @cart.cart_items.includes(:product)
  end

  def add_item
    quantity = params[:quantity]&.to_i || 1

    @cart.add_product(@product, quantity)
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: cart_path, notice: 'Item added to cart successfully.') }
      format.json { render json: { status: 'success', cart_count: @cart.total_items, message: 'Item added to cart' } }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to products_path, alert: 'Product not found.' }
      format.json { render json: { status: 'error', message: 'Product not found' } }
    end
  end

  def remove_item
    @cart.remove_product(@product)
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: cart_path, notice: 'Item removed from cart.') }
      format.json { render json: { status: 'success', cart_count: @cart.total_items, message: 'Item removed from cart' } }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to cart_path, alert: 'Product not found in cart.' }
      format.json { render json: { status: 'error', message: 'Product not found in cart' } }
    end
  end

  def empty
    @cart.clear
    
    respond_to do |format|
      format.html { redirect_to cart_path, notice: 'Cart has been emptied.' }
      format.json { render json: { status: 'success', cart_count: 0, message: 'Cart emptied' } }
    end
  end

  private

  def set_cart
    if user_signed_in?
      @cart = current_user.find_or_create_cart
    else
      # For guest users, store cart in session
      @cart = Cart.find_by(id: session[:cart_id]) || Cart.create
      session[:cart_id] = @cart.id
    end
  end

  def set_product
    @product = Product.find(params[:product_id])
  end
end