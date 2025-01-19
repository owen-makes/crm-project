Rails.application.routes.draw do
  resources :clients
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks", registrations: "users/registrations" }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :leads, except: [ :new, :create ]

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
