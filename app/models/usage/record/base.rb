class Usage::Record::Base
  attr_accessor :account, :start_date, :end_date

  delegate :sid, :to => :account, :prefix => true
  delegate :description, :category, :count_unit, :usage_unit, :price_unit, :to => :class

  def initialize(params = {})
    self.account = params[:account]
    self.start_date = params[:start_date]
    self.end_date = params[:end_date]
  end
end
