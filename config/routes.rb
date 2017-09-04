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
      resources :phone_calls, :only => [:create, :show] do
        resources :recordings, :only => :index
      end

      resources :recordings, :only => [:show]
      resources :incoming_phone_numbers, :only => [:show]
      namespace "usage" do
        resource :records, :only => :show
      end
    end

    post "/2010-04-01/Accounts/:account_id/Calls", :to => "phone_calls#create", :as => :twilio_account_calls
    get "/2010-04-01/Accounts/:account_id/Calls/:id", :to => "phone_calls#show", :as => :twilio_account_call

    get("/2010-04-01/Accounts/:account_id/Recordings/:id", :to => "recordings#show", :as => :twilio_account_recording, :defaults => {:format => "wav"})

    get("/2010-04-01/Accounts/:account_id/Calls/:phone_call_id/Recordings", :to => "recordings#index", :as => :twilio_account_phone_call_recordings)

    get "/2010-04-01/Accounts/:account_id/IncomingPhoneNumbers/:id", :to => "incoming_phone_numbers#show", :as => :twilio_account_incoming_phone_number

    get "/2010-04-01/Accounts/:account_id/Usage/Records", :to => "usage/records#show", :as => :twilio_account_usage_records

    namespace :admin do
      resources :phone_calls, :only => [:create, :show] do
        resources :phone_call_events, :only => [:create, :show]
      end
      resources :call_data_records, :only => [:create]
      resources :aws_sns_messages, :only => [:create]
    end
  end
end
