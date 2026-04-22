Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    resources :contacts, only: [ :index, :show, :create, :update, :destroy ]
  end
end
