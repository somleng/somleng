class Usage::Record::Collection
  include ActiveModel::Serializers::JSON
  include TwilioJson

  attr_accessor :account, :category, :start_date, :end_date

  def initialize(params = {})
    self.account = params["account"]
    self.category = params["Category"]
    self.start_date = params["StartDate"]
    self.end_date = params["EndDate"]
  end

  def attributes
    {}
  end

  def usage_records
    [
      usage_record_calls
    ]
  end

  def usage_record_calls
    @usage_record_calls ||= Usage::Record::Calls.new(
      :account => account, :start_date => start_date, :end_date => end_date
    )
  end

  private

  def json_attributes
    {}
  end

  def json_methods
    {
      :usage_records => nil
    }
  end
end
