Rails.application.routes.draw do
  namespace "api" do
    resources :accounts, :only => [] do
      resources :outgoing_calls, :only => :create
    end
  end

  post "/2010-04-01/Accounts/:account_id/Calls", :to => "api/outgoing_calls#create", :as => :twilio_api_account_calls
end
