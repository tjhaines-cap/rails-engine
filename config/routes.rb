Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      get '/merchants/find', to: "merchants#find"
      get '/items/find_all', to: "items#find_all"
      
      get '/merchants/most_items', to: "merchants#most_items"

      get '/revenue', to: 'merchants#total_revenue'

      resources :merchants, only: %i[index show] do
        resources :items, only: %i[index], controller: :merchant_items
      end

      resources :items, only: %i[index show create update destroy] do
        resources :merchant, only: %i[index], controller: :item_merchant
      end

      namespace :revenue do
        resources :merchants, only: [:index]
      end

    end
  end
end
