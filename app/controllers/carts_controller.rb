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
      format.html { 
        flash[:notice] = "Added to your cart"
        redirect_back(fallback_location: cart_path) 
      }
      format.json { 
        render json: { 
          status: 'success', 
          cart_count: @cart.total_items,
          cart_total: @cart.total_price,
          message: 'Item added to cart' 
        } 
      }
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

  def remove_item
    @cart.remove_product(@product)
    
    respond_to do |format|
      format.html { 
        flash[:notice] = "Removed from your cart"
        redirect_back(fallback_location: cart_path) 
      }
      format.json { 
        render json: { 
          status: 'success', 
          cart_count: @cart.total_items,
          cart_total: @cart.total_price,
          message: 'Item removed from cart' 
        } 
      }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { 
        flash[:alert] = "Product not found in cart"
        redirect_to cart_path 
      }
      format.json { render json: { status: 'error', message: 'Product not found in cart' } }
    end
  end

  def empty
    @cart.clear
    
    respond_to do |format|
      format.html { 
        flash[:notice] = "Cart has been emptied"
        redirect_to cart_path 
      }
      format.json { 
        render json: { 
          status: 'success', 
          cart_count: 0,
          cart_total: 0,
          message: 'Cart emptied' 
        } 
      }
    end
  end

  private

  def set_cart
    @cart = current_cart
  end

  def set_product
    @product = Product.find(params[:product_id])
  end
end
