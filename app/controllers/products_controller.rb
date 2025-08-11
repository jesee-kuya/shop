# ProductsController handles all product-related operations in the e-commerce system
#
# This controller manages the full CRUD lifecycle for products, including:
# - Public browsing of products (index, show) - available to all users
# - Product creation, editing, and deletion - restricted to authenticated users
# - Authorization ensuring users can only modify their own products
# - Support for both HTML and JSON responses for API compatibility
#
# Authentication & Authorization:
# - index/show actions are public (anyone can browse products)
# - new/create/edit/update/destroy require user authentication
# - edit/update/destroy additionally require ownership authorization
#
# Key Features:
# - Products are automatically associated with the current user
# - Comprehensive error handling and user feedback
# - RESTful design with standard Rails conventions
# - Image upload support through CarrierWave integration
class ProductsController < ApplicationController
  # Set up the product instance for actions that need it
  # This reduces code duplication and ensures consistent product loading
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]

  # Override the default authentication requirement from ApplicationController
  # Allow public access to index and show actions for product browsing
  before_action :authenticate_user!, except: [:index, :show]

  # Ensure only product owners can modify their products
  # This authorization check runs after authentication for destructive actions
  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  # GET /products or /products.json
  # Display all products in the system, ordered by creation date (newest first)
  # This is the main product browsing page, accessible to all users
  #
  # @return [void] Renders index template with @products instance variable
  def index
    @products = Product.all.order("created_at desc")
  end

  # GET /products/1 or /products/1.json
  # Display detailed information for a specific product
  # Accessible to all users for product browsing
  #
  # Note: There's a variable naming inconsistency here (@products vs @product)
  # This should be @product for consistency with Rails conventions
  #
  # @return [void] Renders show template with product details
  def show
    @products = Product.find(params[:id])
  end

  # Custom method for direct database access (currently unused)
  # This method bypasses ActiveRecord and queries the database directly
  # Generally not recommended unless there are specific performance requirements
  #
  # @param id [Integer] The product ID to find
  # @return [Hash] Raw database row as a hash
  def find_product_by_id(id)
    connection.execute("SELECT * FROM products WHERE products.id = ? LIMIT 1", id).first
  end

  # GET /products/new
  # Display form for creating a new product
  # Only accessible to authenticated users
  # Builds a new product associated with the current user
  #
  # @return [void] Renders new template with empty product form
  def new
    @product = current_user.products.build
  end

  # GET /products/1/edit
  # Display form for editing an existing product
  # Only accessible to the product owner (enforced by authorize_owner!)
  # Uses @product set by set_product before_action
  #
  # @return [void] Renders edit template with populated product form
  def edit
    # @product is already set by set_product before_action
  end

  # POST /products or /products.json
  # Create a new product with the submitted parameters
  # Associates the product with the current user automatically
  # Supports both HTML and JSON responses for API compatibility
  #
  # Success: Redirects to product show page with success message
  # Failure: Re-renders new form with validation errors
  #
  # @return [void] Redirects or renders based on save success/failure
  def create
    @product = current_user.products.build(product_params)

    respond_to do |format|
      if @product.save
        # Product created successfully
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        # Validation errors occurred
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  # Update an existing product with the submitted parameters
  # Only accessible to the product owner (enforced by authorize_owner!)
  # Supports both HTML and JSON responses for API compatibility
  #
  # Success: Redirects to product show page with success message
  # Failure: Re-renders edit form with validation errors
  #
  # @return [void] Redirects or renders based on update success/failure
  def update
    respond_to do |format|
      if @product.update(product_params)
        # Product updated successfully
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        # Validation errors occurred
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  # Delete an existing product from the system
  # Only accessible to the product owner (enforced by authorize_owner!)
  # Supports both HTML and JSON responses for API compatibility
  #
  # Success: Redirects to products index with success message
  # Note: Product deletion may be prevented by the before_destroy callback
  #       if the product is referenced by cart items
  #
  # @return [void] Redirects to products index or returns JSON response
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_path, notice: "Product was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private

  # Load the product for actions that need it
  # Used by before_action to set @product for show, edit, update, destroy
  # Raises ActiveRecord::RecordNotFound if product doesn't exist
  #
  # @return [void] Sets @product instance variable
  def set_product
    @product = Product.find(params[:id])
  end

  # Define which parameters are allowed for product creation/updates
  # This prevents mass assignment vulnerabilities by whitelisting safe parameters
  # All product attributes are included for complete form functionality
  #
  # @return [ActionController::Parameters] Filtered parameters hash
  def product_params
    params.require(:product).permit(:brand, :model, :description, :condition, :finish, :title, :price, :image)
  end

  # Ensure only the product owner can perform destructive actions
  # This authorization check prevents users from modifying others' products
  # Redirects unauthorized users with an error message
  #
  # @return [void] Redirects if user is not authorized, otherwise continues
  def authorize_owner!
    unless current_user && current_user == @product.user
      redirect_to products_path, alert: "You are not authorized to perform this action."
    end
  end
end
