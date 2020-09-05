Rails.application.routes.draw do
  root to: redirect("https://www.somleng.org")

  namespace :services, defaults: { format: "json" } do
    resources :inbound_phone_calls, only: :create
    resources :phone_call_events, only: :create
    resources :call_data_records, only: :create
  end

  namespace :api, defaults: { format: "json" } do
    post "/2010-04-01/Accounts/:account_id/Calls", to: "phone_calls#create", as: :twilio_account_calls
    get "/2010-04-01/Accounts/:account_id/Calls/:id", to: "phone_calls#show", as: :twilio_account_call

    namespace :internal do
      resources :call_data_records, only: [:create]
    end
  end
end
