require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
   
  resources :products
  get "up" => "rails/health#show", as: :rails_health_check

  post '/cart', to: 'carts#create'
  get '/cart', to: 'carts#show'
  patch '/cart/add_item', to: 'carts#update'
  delete '/cart/:product_id', to: 'carts#delete'

  root "rails/health#show"
end
