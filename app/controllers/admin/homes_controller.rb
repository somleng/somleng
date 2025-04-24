module Admin
  class HomesController < Admin::ApplicationController
    def index
      @dashboard = HomeDashboard.new
    end
  end
end
