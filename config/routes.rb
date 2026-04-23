Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    resources :contacts, only: [ :index, :show, :create, :update, :destroy ] do
      resources :contact_methods, only: [ :create, :destroy ]
      resources :important_dates,  only: [ :create, :destroy ]
    end
  end
end
