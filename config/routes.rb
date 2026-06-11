Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker, defaults: { format: :js }

  # Defines the root path route ("/")
  get "magic/:token", to: "magic_links#consume", as: :magic
  post "login", to: "magic_links#request_login"
  root "sessions#new"
  resource :session, only: [:create, :destroy]
  resource :account, only: [:show, :update]
  post "account/email", to: "accounts#request_verification"
  resources :predictions, only: [:index, :create]
  resource :special_prediction, only: [:create]
  resources :results, only: [:index]
  resources :standings, only: [:index]
  resources :groups, only: [:index]
  resources :tournaments, only: [:index], path: "torneos" do
    post :join_general, on: :member
  end
  resources :pools, only: [:index, :create, :show, :update], path: "pollas"
  post "pollas/:id/select", to: "pools#select", as: :select_pool
  get  "unirse/:token", to: "memberships#new", as: :join
  post "unirse/:token", to: "memberships#create"

  namespace :admin do
    get  "login", to: "sessions#new"
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"
    resources :tournaments, only: [:index, :create] do
      member do
        patch :activate
        post  :select
        post  :import_fixtures
      end
    end
    resources :matches, only: [:index, :edit, :update]
    resources :results, only: [:index, :update]
    resource :resolution, only: [:show, :update]
  end
end
