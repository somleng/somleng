class Usage::Record
  attr_accessor :account, :category, :start_date, :end_date

  def initialize(params = {})
    self.account = params["account"]
    self.category = params["Category"]
    self.start_date = params["StartDate"]
    self.end_date = params["EndDate"]
  end
end
