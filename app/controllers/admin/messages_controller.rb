module Admin
  class MessagesController < Admin::ApplicationController
    def scoped_resource
      Message.where(internal: false)
    end
  end
end
