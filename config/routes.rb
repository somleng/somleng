Rails.application.routes.draw do
  devise_for :users, skip: %i[registrations invitations]

  constraints subdomain: "dashboard" do
    devise_scope :user do
      resource(
        :registration,
        only: %i[edit update],
        controller: "users/registrations",
        as: :user_registration,
        path: "users"
      )

      resource(
        :invitation,
        only: :update,
        controller: "users/invitations",
        as: :user_invitation,
        path: "users/invitation"
      ) do
        get :accept, action: :edit
      end

      root to: "dashboard/home#show"
    end

    scope "/", module: :dashboard, as: :dashboard do
      resources :two_factor_authentications, only: %i[new create destroy]
      resources :accounts
      resources :account_memberships
      resources :outbound_sip_trunks
      resources :users
      resources :exports, only: %i[index create]
      resource :account_session, only: :create
      resource :account_settings, only: %i[show edit update]
      resource :carrier_settings, only: %i[show edit update]
      resource :home, only: :show
      resources :user_invitations, only: :update
      resources :phone_numbers
      resources :phone_number_configuration, only: %i[edit update]
      resources :inbound_sip_trunks
      resources :phone_calls, only: %i[index show]

      root to: "home#show"
    end

    namespace :admin do
      concern :exportable do
        get :export, on: :collection
      end

      resources :carriers, only: %i[show index], concerns: :exportable
      resources :accounts, only: %i[show index], concerns: :exportable
      resources :phone_calls, only: %i[show index], concerns: :exportable

      resources :inbound_sip_trunks, only: :show
      resources :outbound_sip_trunks, only: :show
      resources :phone_numbers, only: :show
      resources :phone_call_events, only: :show
      resources :call_data_records, only: :show

      root to: "phone_calls#index"
    end
  end

  constraints subdomain: %w[api] do
    namespace :services, defaults: { format: "json" } do
      resources :inbound_phone_calls, only: :create
      resources :phone_call_events, only: :create
      resources :call_data_records, only: :create
      resource :dial_string, only: :create
    end

    scope "/2010-04-01/Accounts/:account_id", module: :twilio_api, as: :twilio_api_account,
                                              defaults: { format: "json" } do
      resources :phone_calls, only: %i[create show update], path: "Calls"
      post "Calls/:id" => "phone_calls#update"
    end

    scope :carrier, as: :carrier_api, module: :carrier_api do
      namespace :v1, defaults: { format: :json } do
        resources :accounts, only: %i[create show update index]
        resources :events, only: %i[index show]

        resources :phone_calls, only: %i[index show update]
      end
    end
  end
end
