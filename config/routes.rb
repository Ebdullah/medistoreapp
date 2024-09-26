require 'sidekiq/web'

Rails.application.routes.draw do
  get 'dashboards/index'
  root "branches#index"

  devise_for :users
  resources :users

  resources :branches do 
    resources :records do 
      member do
        get 'pdf'
      end
    end
    resources :audit_logs
    resources :medicines
    resources :stock_transfers do
      member do
        put :approve
        put :deny
      end
    end
  end

  get 'dashboard', to: 'dashboards#index'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
  mount Sidekiq::Web => '/sidekiq'
end
