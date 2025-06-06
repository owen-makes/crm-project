require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users, controllers: {
     omniauth_callbacks: "users/omniauth_callbacks",
     sessions: "users/sessions",
     registrations: "users/registrations",
     invitations: "users/invitations"
     }

  delete "/users/invitation/:id", to: "users/invitations#destroy", as: :delete_user_invitation

  # Sidekiq interface (delete or find another type of auth for prod)
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  resources :users, only: [] do
    get "profile", to: "profiles#show"
  end

  # For managing current user's own profile
  resource :profile, only: [ :edit, :update ]

  resources :securities, only: [ :index, :show ]

  resources :leads, except: [ :new, :create ] do
    member do
      post :convert
      patch :assign
    end
  end

  resources :clients do
    resources :portfolios do
      get :summary, on: :member
    end
  end

  resources :portfolios do
    resources :holdings
  end

  resources :csv_imports do
    member do
      get :map_headers
      get :choose_rows
      post :import
    end
  end

  resource :team do
    resources :broker_credentials
    member do
      patch :remove_from_team
    end
  end

  get "team/join/:token", to: "teams#join_via_link", as: :join_team_link

  get "/signup/:form_token", to: "leads#new", as: "new_lead_form"
  post "/signup/:form_token", to: "leads#create"
  get "/thank_you", to: "leads#thank_you", as: "thank_you"


  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "leads#index"
end
