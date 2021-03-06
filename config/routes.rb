require "sidekiq/web"
require "admin_constraint"

Rails.application.routes.draw do
  mount RailsAdmin::Engine => "/admin", as: :rails_admin
  mount Sidekiq::Web => "/sidekiq", constraints: AdminConstraint.new

  root "pages#index"

  get "/auth/:provider/callback", to: "omniauth_callbacks#create"
  get "/auth/failure", to: "omniauth_callbacks#failure"

  resource :profile, only: %i[show update destroy]

  resources :pull_requests, only: %i[index update] do
    get :status, on: :collection
  end
  resources :repositories, only: %i[index]
  resources :hooks, only: %i[create]
end
