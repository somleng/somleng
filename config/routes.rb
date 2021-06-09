Rails.application.routes.draw do
  devise_for :users, skip: %i[registrations invitations]

  devise_scope :user do
    resource(
      :registration,
      only: %i[edit update],
      controller: "devise/registrations",
      as: :user_registration,
      path: "users"
    )

    resource(
      :invitation,
      only: :update,
      controller: "devise/invitations",
      as: :user_invitation,
      path: "users/invitation"
    ) do
      get :accept, action: :edit
    end

    root to: "dashboard/home#show"
  end

  namespace :services, defaults: { format: "json" } do
    resources :inbound_phone_calls, only: :create
    resources :phone_call_events, only: :create
    resources :call_data_records, only: :create
    resource :dial_string, only: :create
  end

  scope "/2010-04-01/Accounts/:account_id", as: :account, defaults: { format: "json" } do
    resources :phone_calls, only: %i[create show update], path: "Calls",
                            controller: "twilio_api/phone_calls"
    post "Calls/:id" => "twilio_api/phone_calls#update"
  end

  namespace :dashboard do
    resource :two_factor_authentication, only: %i[new create]
    resources :accounts
    resources :account_memberships
    resources :outbound_sip_trunks
    resources :users
    resources :exports, only: %i[index create]
    resource :account_session, only: %i[create destroy]
    resource :account_settings, only: %i[show edit update]
    resource :carrier_settings, only: %i[show edit update]
    resource :home, only: :show
    resources :user_invitations, only: :update

    root to: "home#show"
  end
end
