Rails.application.routes.draw do
  root "pages#index"

  get "/auth/:provider/callback", to: "omniauth_callbacks#create"
  get "/auth/failure", to: "omniauth_callbacks#failure"

  resource :profile, only: %i[show update destroy]

  resources :pull_requests, only: %i[index update]
  resources :hooks, only: %i[create]
end
