Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users,
    skip:        [ :registrations, :passwords ],
    controllers: { sessions: "users/sessions" }

  authenticate :user do
    root "dashboard#show"

    get "prospecting", to: "prospecting#show", as: :prospecting

    resources :contacts do
      resources :interactions, only: [ :create ]
    end

    resource :sunday_checklist, only: [ :update ]
  end
end
