Rails.application.routes.draw do
  devise_for :users
  root 'products#index'
  
  resources :products
  resources :cart_items, except: [:new, :edit]
  
  # Add cart route for convenience
  get 'cart', to: 'cart_items#index'
end
