Rails.application.routes.draw do
  root to: redirect("https://github.com/somleng/twilreapi")

  namespace :services, defaults: { format: "json" } do
    resources :inbound_phone_calls, only: :create
  end

  namespace :api, defaults: { format: "json" } do
    resources :accounts, only: [] do
      resources :phone_calls, only: %i[create show] do
        resources :recordings, only: :index
      end

      resources :recordings, only: [:show]
      resources :incoming_phone_numbers, only: [:show]
    end

    post "/2010-04-01/Accounts/:account_id/Calls", to: "phone_calls#create", as: :twilio_account_calls
    get "/2010-04-01/Accounts/:account_id/Calls/:id", to: "phone_calls#show", as: :twilio_account_call

    get("/2010-04-01/Accounts/:account_id/Recordings/:id", to: "recordings#show", as: :twilio_account_recording, defaults: { format: "wav" })

    get("/2010-04-01/Accounts/:account_id/Calls/:phone_call_id/Recordings", to: "recordings#index", as: :twilio_account_call_recordings)

    get "/2010-04-01/Accounts/:account_id/IncomingPhoneNumbers/:id", to: "incoming_phone_numbers#show", as: :twilio_account_incoming_phone_number

    namespace :internal do
      resources :phone_calls, only: %i[create show] do
        resources :phone_call_events, only: %i[create show]
      end
      resources :call_data_records, only: [:create]
      resources :aws_sns_messages, only: [:create]
    end
  end
end
