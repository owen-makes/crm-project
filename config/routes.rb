Rails.application.routes.draw do
  resources :clients
  devise_for :users, controllers: {
     omniauth_callbacks: "users/omniauth_callbacks",
     sessions: "users/sessions",
     registrations: "users/registrations",
     invitations: "users/invitations"
     }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # resources :leads

  resources :leads, except: [ :new, :create ] do
    member do
      post :convert
    end
  end

  resource :team

  get "team/join/:token", to: "teams#join_via_link", as: :join_team_link


  # resources :invitations, only: [ :new, :create ]
  # get "/invitations/accept/:token", to: "invitations#accept", as: :accept_invitation


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
