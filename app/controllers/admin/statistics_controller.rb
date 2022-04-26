module Admin
  class StatisticsController < Admin::ApplicationController
    def index
      @dashboard = StatisticDashboard.new(request.query_parameters[:search])
    end
  end
end
