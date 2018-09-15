Rails.application.routes.draw do
  root "profiles#show"

  get "/auth/:provider/callback", to: "omniauth_callbacks#create"
  get "/auth/failure", to: "omniauth_callbacks#failure"

  resource :profile, only: %i[show update destroy]

  namespace :admin do
    resources :pull_requests, only: %i[index update]
  end

  resources :hooks, only: %i[create]
end
