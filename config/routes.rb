Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :teams
  resources :players do
    member do
      post :purchase
    end
  end
  resources :matches, only: [:index, :show, :destroy] do
    collection do
      post :make_available
      delete :remove_from_queue
    end
  end
  resources :player_contracts do
    member do
      post :expire
    end
  end
  resources :wallets, only: [:show, :update]
  
  post 'mark_notifications_viewed', to: 'pages#mark_notifications_viewed'
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
