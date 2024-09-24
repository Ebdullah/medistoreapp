Rails.application.routes.draw do
  root "branches#index"
  devise_for :users

  resources :branches do 
    resources :records
    resources :audit_logs
    resources :medicines
    resources :stock_transfers do
      member do
        put :approve
        put :deny
      end
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :stock_transfers

  # Defines the root path route ("/")
  # root "posts#index"
end
