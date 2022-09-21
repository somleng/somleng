Rails.application.routes.draw do
  scope(as: :api, constraints: { subdomain: AppSettings.config_for(:api_subdomain) }, defaults: { format: "json" } ) do
    concern :recordings do
      resources :recordings, only: %i[index], path: "Recordings"
      resources :recordings, only: %i[show], path: "Recordings", defaults: { format: "wav" }
    end

    scope "/2010-04-01/Accounts/:account_id", module: :twilio_api, as: :twilio_account do
      concerns :recordings

      resources :phone_calls, only: %i[index create show update], path: "Calls", concerns: :recordings
      post "Calls/:id" => "phone_calls#update"
    end

    scope "/carrier", as: :carrier, module: :carrier_api do
      namespace :v1, defaults: { format: :json } do
        resources :accounts, only: %i[create show update index destroy]
        resources :events, only: %i[index show]

        resources :phone_calls, only: %i[index show update]
        resources :phone_numbers, only: %i[index create show update destroy] do
          patch :release, on: :member
        end
      end
    end

    namespace :services do
      resources :inbound_phone_calls, only: :create
      resources :phone_call_events, only: :create
      resources :call_data_records, only: :create
      resources :recordings, only: %i[create update]
      resource :dial_string, only: :create
      resource :routing_parameters, only: :create
    end
  end

  constraints(AppSubdomainConstraint.new) do
    devise_for :users, skip: %i[registrations invitations]

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
        controller: "devise/invitations",
        as: :user_invitation,
        path: "users/invitation"
      ) do
        get :accept, action: :edit
      end

      root to: "dashboard/home#show"
    end

    scope "/docs", as: :docs do
      get "/", to: redirect("https://www.somleng.org/carrier_documentation.html")
      get "/api", to: "twilio_api/documentation#show", as: :twilio_api
    end

    scope module: :dashboard, as: :dashboard do
      resources :two_factor_authentications, only: %i[new create destroy]
      resources :accounts
      resources :account_memberships
      resources :sip_trunks
      resources :carrier_users
      resources :exports, only: %i[index create]
      resources :imports, only: %i[index create]
      resource :account_session, only: :create
      resource :account_settings, only: %i[show edit update]
      resource :carrier_settings, only: %i[show edit update]
      resource :home, only: :show
      resources :user_invitations, only: :update
      resources :phone_numbers do
        resource :configuration, controller: "phone_number_configurations", only: %i[edit update]
        patch :release, on: :member
      end
      resources :phone_calls, only: %i[index show]
      resources :error_logs, only: :index
      resources :events, only: %i[index show]
      resources :webhook_request_logs, only: %i[index show]

      root to: "home#show"
    end
  end

  constraints(subdomain: AppSettings.config_for(:app_subdomain)) do
    devise_scope :user do
      resource(
        :registration,
        only: %i[new create],
        controller: "users/registrations",
        as: :user_registration,
        path: "users",
        path_names: {
          new: "sign_up"
        }
      )
    end

    resource :forgot_subdomain, only: [], controller: "users/forgot_subdomain", path: "users" do
      get   :new,     path: "forgot_subdomain", as: "new"
      post  :create,  path: "forgot_subdomain"
    end

    namespace :admin do
      resources :carriers, only: %i[show index]
      resources :accounts, only: %i[show index]
      resources :phone_calls, only: %i[show index]
      resources :users, only: %i[show index]
      resources :statistics, only: :index
      resources :error_logs, only: %i[show index]
      resources :events, only: %i[index show]
      resources :webhook_request_logs, only: %i[index show]

      resources :account_memberships, only: :show
      resources :sip_trunks, only: :show
      resources :phone_numbers, only: :show
      resources :phone_number_configurations, only: :show
      resources :phone_call_events, only: :show
      resources :call_data_records, only: :show
      resources :recordings, only: :show

      root to: "statistics#index"
    end

    root to: redirect("/users/forgot_subdomain"), as: :app_root
  end
end
