Rails.application.routes.draw do
  if Rails.application.secrets[:active_job_queue_adapter] == "sidekiq"
    require "sidekiq/web"

    if Rails.env.production?
      if (sidekiq_username = Rails.application.secrets[:sidekiq_web_http_basic_username]) && (sidekiq_password = Rails.application.secrets[:sidekiq_web_http_basic_password])
        Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
          username == sidekiq_username && password == sidekiq_password
        end
      end
    end

    mount Sidekiq::Web => '/sidekiq'
  end

  root :to => redirect('https://github.com/dwilkie/twilreapi')

  namespace "api", :defaults => { :format => "json" } do
    resources :accounts, :only => [] do
      resources :phone_calls, :only => [:create, :show]
      resources :incoming_phone_numbers, :only => [:show]
    end

    post "/2010-04-01/Accounts/:account_id/Calls", :to => "phone_calls#create", :as => :twilio_account_calls
    get "/2010-04-01/Accounts/:account_id/Calls/:id", :to => "phone_calls#show", :as => :twilio_account_call

    get "/2010-04-01/Accounts/:account_id/IncomingPhoneNumbers/:id", :to => "incoming_phone_numbers#show", :as => :twilio_account_incoming_phone_number

    namespace :admin do
      resources :phone_calls, :only => [:create, :show]
      resources :call_data_records, :only => [:create, :show]
    end
  end
end
