Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    resources :people, only: [ :index, :show, :create, :update, :destroy ] do
      resources :contact_methods, only: [ :create, :destroy ]
      resources :important_dates, only: [ :create, :destroy ]
    end

    resources :reminders, only: [] do
      member do
        post :dismiss
        post :snooze
      end
    end

    get "dashboard/reconnect", to: "dashboard#reconnect"
    get "dashboard/upcoming",  to: "dashboard#upcoming"
  end
end
