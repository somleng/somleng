Rails.application.routes.draw do
  root to: redirect("https://www.somleng.org")

  namespace :services, defaults: { format: "json" } do
    resources :inbound_phone_calls, only: :create
    resources :phone_call_events, only: :create
    resources :call_data_records, only: :create
    resource :dial_string, only: :create
  end

  scope "/2010-04-01/Accounts/:account_id", as: :account, defaults: { format: "json" } do
    resources :phone_calls, only: %i[create show], path: "Calls", controller: "api/phone_calls"
  end
end
