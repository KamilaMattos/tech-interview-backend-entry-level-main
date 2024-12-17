class CartsController < ApplicationController
    before_action :set_cart, only: %i[show add_product update_item remove_item]
    before_action :validate_add_params!, only: %i[add_product]
    before_action :validate_update_params!, only: %i[update_item]

    # POST /cart
    def create
      product = find_product(params[:product_id])
      return render json: { error: 'Product not found' }, status: :not_found unless product
  
      cart_item = @cart.cart_items.find_or_initialize_by(product: product)
  
      cart_item.assign_attributes(
        quantity: cart_item.quantity + params[:quantity].to_i,
        unit_price: product.price
      )
      cart_item.save!
  
      @cart.update_total_price!
      render json: CartPresenter.new(@cart).as_json, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { error: 'Something went wrong' }, status: :internal_server_error
    end
  
    # GET /cart
    def show
      render json: CartPresenter.new(@cart).as_json, status: :ok
    end

    # PATCH /cart/add_item
    def update
      product = find_product(params[:product_id])
      return render json: { error: 'Product not found' }, status: :not_found unless product
  
      cart_item = @cart.cart_items.find_by(product: product)
  
      if cart_item
        new_quantity = cart_item.quantity + params[:quantity].to_i
        if new_quantity <= 0
          cart_item.destroy!
        else
          cart_item.update!(quantity: new_quantity)
        end
      else
        return render json: { error: 'Product not in cart' }, status: :not_found
      end
  
      @cart.update_total_price!
      render json: CartPresenter.new(@cart).as_json, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { error: 'Something went wrong' }, status: :internal_server_error
    end
  
    # DELETE /cart/:product_id
    def delete
      product = find_product(params[:product_id])
      return render json: { error: 'Product not found' }, status: :not_found unless product
  
      cart_item = @cart.cart_items.find_by(product: product)
      if cart_item
        cart_item.destroy!
        @cart.update_total_price!
      else
        return render json: { error: 'Product not in cart' }, status: :not_found
      end
  
      render json: CartPresenter.new(@cart).as_json, status: :ok
    end
  
    private
  
    def set_cart
      @cart = Cart.find_by(id: session[:cart_id]) || create_cart
    end
  
    def create_cart
      cart = Cart.create!(total_price: 0)
      session[:cart_id] = cart.id
      cart
    end
  
    def validate_add_params!
      unless params[:product_id].present? && params[:quantity].to_i.positive?
        render json: { error: 'Invalid parameters' }, status: :bad_request
      end
    end
  
    def validate_update_params!
      unless params[:product_id].present? && params[:quantity].is_a?(Integer)
        render json: { error: 'Invalid parameters' }, status: :bad_request
      end
    end
  
    def find_product(product_id)
      Product.find_by(id: product_id)
    end
  end
  
  class CartPresenter
    def initialize(cart)
      @cart = cart
    end
  
    def as_json
      {
        id: @cart.id,
        products: @cart.cart_items.includes(:product).map do |item|
          {
            id: item.product.id,
            name: item.product.name,
            quantity: item.quantity,
            unit_price: item.unit_price,
            total_price: item.quantity * item.unit_price
          }
        end,
        total_price: @cart.total_price
      }
    end
  end
  