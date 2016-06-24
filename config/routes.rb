Rails.application.routes.draw do
  root :to => redirect('https://github.com/dwilkie/twilreapi')

  namespace "api", :defaults => { :format => "json" } do
    resources :accounts, :only => [] do
      resources :phone_calls, :only => [:create, :show]
    end

    post "/2010-04-01/Accounts/:account_id/Calls", :to => "phone_calls#create", :as => :twilio_account_calls
    get "/2010-04-01/Accounts/:account_id/Calls/:id", :to => "phone_calls#show", :as => :twilio_account_call
  end
end
