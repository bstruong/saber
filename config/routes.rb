Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users,
    path:        "api/users",
    path_names:  { sign_in: "sign_in", sign_out: "sign_out" },
    defaults:    { format: :json },
    skip:        [ :registrations, :passwords ],
    controllers: { sessions: "api/sessions" }

  namespace :api do
    get "users/me", to: "users#me"

    resources :people, only: [ :index, :show, :create, :update, :destroy ] do
      resources :contact_methods, only: [ :create, :destroy ]
      resources :important_dates, only: [ :create, :destroy ]
      resources :interactions,    only: [ :index, :show, :create ] do
        member do
          post :void
        end
      end
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
