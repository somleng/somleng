module Admin
  class PhoneCallsController < Admin::ApplicationController
    def scoped_resource
      PhoneCall.where(internal: false)
    end
  end
end
