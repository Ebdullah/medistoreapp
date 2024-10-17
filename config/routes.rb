require 'sidekiq/web'

Rails.application.routes.draw do
  get 'dashboard', to: 'dashboard#index'
  # root "branches#index"
  devise_scope :user do
    root 'users/sessions#new'
  end
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }
  resources :users, only: [:index, :new, :create, :edit, :update, :destroy] do 
    get 'portal', on: :collection, as: 'portal'
    get 'profile'
  end


  get 'select_branch_for_purchase', to: 'records#select_branch_for_purchase'
  get 'my_purchases', to: 'records#my_purchases', as: 'my_purchases'

  resources :branches do 
    resources :archives, only: [:index, :create]
    resources :refunds, only: [:create, :update, :new, :index] do 
      member do 
        put :approve
        put :deny
      end
    end
    resources :records do 
      collection do
        get :purchase 
        post :create_purchase
      end
      member do
        post :undo, to: 'records#undo'
        get 'show_purchase'
        get 'pdf'
      end
    end
    resources :audit_logs
    resources :medicines do
      member do
        get :price
      end
      collection do
        get 'expired'
      end
    end
    resources :stock_transfers do
      member do
        put :approve
        put :deny
        get 'pdf'
        patch :upload_pdf
      end
    end
  end

  resources :notifications, only: [:index, :show, :destroy]

  get 'dashboard', to: 'dashboards#index'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
  mount Sidekiq::Web => '/sidekiq'
end
