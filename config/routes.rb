Rails.application.routes.draw do
  devise_for :users, skip: %i[registrations invitations]

  constraints subdomain: "dashboard" do
    devise_scope :user do
      resource(
        :registration,
        only: %i[edit update new create],
        controller: "users/registrations",
        as: :user_registration,
        path: "users",
        path_names: {
          new: "sign_up"
        }
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
      resources :carrier_users
      resources :exports, only: %i[index create]
      resource :account_session, only: :create
      resource :account_settings, only: %i[show edit update]
      resource :carrier_settings, only: %i[show edit update]
      resource :home, only: :show
      resources :user_invitations, only: :update
      resources :phone_numbers do
        resource :configuration, controller: "phone_number_configurations", only: %i[edit update]
      end
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
      resources :recordings, only: :show

      root to: "phone_calls#index"
    end
  end

  constraints subdomain: %w[api] do
    namespace :services, defaults: { format: "json" } do
      resources :inbound_phone_calls, only: :create
      resources :phone_call_events, only: :create
      resources :call_data_records, only: :create
      resources :recordings, only: %i[create update]
      resource :dial_string, only: :create
    end

    concern :recordings do
      resources :recordings, only: %i[index], path: "Recordings"
      resources :recordings, only: %i[show], path: "Recordings", defaults: { format: "wav" }
    end

    scope "/2010-04-01/Accounts/:account_id", module: :twilio_api, as: :twilio_api_account,
                                              defaults: { format: "json" } do
      concerns :recordings

      resources :phone_calls, only: %i[index create show update], path: "Calls",
                              concerns: :recordings
      post "Calls/:id" => "phone_calls#update"
    end

    scope :carrier, as: :carrier_api, module: :carrier_api do
      namespace :v1, defaults: { format: :json } do
        resources :accounts, only: %i[create show update index]
        resources :events, only: %i[index show]

        resources :phone_calls, only: %i[index show update]
        resources :phone_numbers, only: %i[index create show update] do
          patch :release, on: :member
        end
      end
    end
  end
end
