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
      format.html { 
        flash[:notice] = "Added to your cart"
        redirect_to cart_items_path 
      }
      format.json { render json: { status: 'success', cart_count: @cart.total_items, message: 'Item added to cart' } }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { 
        flash[:alert] = "Product not found"
        redirect_to products_path 
      }
      format.json { render json: { status: 'error', message: 'Product not found' } }
    end
  end

  def update
    quantity = params[:quantity].to_i
    
    if @cart.update_quantity(@cart_item.product, quantity)
      respond_to do |format|
        format.html { 
          flash[:notice] = "Cart updated successfully"
          redirect_to cart_items_path 
        }
        format.json { render json: { status: 'success', cart_count: @cart.total_items, message: 'Cart updated' } }
      end
    else
      respond_to do |format|
        format.html { 
          flash[:alert] = "Unable to update cart"
          redirect_to cart_items_path 
        }
        format.json { render json: { status: 'error', message: 'Unable to update cart' } }
      end
    end
  end

  def destroy
    @cart.remove_product(@cart_item.product)
    
    respond_to do |format|
      format.html { 
        flash[:notice] = "Removed from your cart"
        redirect_to cart_items_path 
      }
      format.json { render json: { status: 'success', cart_count: @cart.total_items, message: 'Item removed from cart' } }
    end
  end

  private

  def set_cart
    @cart = current_cart
  end

  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  end
end
