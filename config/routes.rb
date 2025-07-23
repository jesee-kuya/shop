Rails.application.routes.draw do
  devise_for :users
  root 'products#index'
  
  resources :products
  resources :cart_items, except: [:new, :edit]
  
  # Cart routes
  resource :cart, only: [:show] do
    post   'add/:product_id',    to: 'carts#add_item',    as: :add_item
    delete 'remove/:product_id', to: 'carts#remove_item', as: :remove_item
    delete 'empty',              to: 'carts#empty',       as: :empty
  end
  
  # Legacy cart route for convenience (redirects to new cart route)
  get 'cart', to: 'carts#show'
end
