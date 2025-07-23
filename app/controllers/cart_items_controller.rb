class CartItemsController < ApplicationController
  before_action :set_cart
  before_action :set_cart_item, only: [:show, :update, :destroy]

  def index
    @cart_items = @cart.cart_items.includes(:product)
  end

  def create
    @product = Product.find(params[:product_id])
    quantity = params[:quantity]&.to_i || 1

    @cart.add_product(@product, quantity)
    
    respond_to do |format|
      format.html { redirect_to cart_items_path, notice: 'Item added to cart successfully.' }
      format.json { render json: { status: 'success', cart_count: @cart.total_items } }
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: 'Product not found.'
  end

  def update
    quantity = params[:quantity].to_i
    
    if @cart.update_quantity(@cart_item.product, quantity)
      respond_to do |format|
        format.html { redirect_to cart_items_path, notice: 'Cart updated successfully.' }
        format.json { render json: { status: 'success', cart_count: @cart.total_items } }
      end
    else
      respond_to do |format|
        format.html { redirect_to cart_items_path, alert: 'Unable to update cart.' }
        format.json { render json: { status: 'error' } }
      end
    end
  end

  def destroy
    @cart.remove_product(@cart_item.product)
    
    respond_to do |format|
      format.html { redirect_to cart_items_path, notice: 'Item removed from cart.' }
      format.json { render json: { status: 'success', cart_count: @cart.total_items } }
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

  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  end
end