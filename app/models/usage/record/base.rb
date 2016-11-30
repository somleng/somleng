class Usage::Record::Base
  include ActiveModel::Serializers::JSON
  include TwilioJson

  attr_accessor :account, :start_date, :end_date

  delegate :sid, :to => :account, :prefix => true
  delegate :description, :category, :count_unit, :usage_unit, :price_unit, :to => :class

  def initialize(params = {})
    self.account = params[:account]
    self.start_date = params[:start_date]
    self.end_date = params[:end_date]
  end

  def attributes
    {}
  end

  def uri
    Rails.application.routes.url_helpers.api_twilio_account_usage_records_path(account, uri_query_params)
  end

  def subresource_uris
    {}
  end

  private

  def uri_query_params
    {
      "Category" => category, "StartDate" => start_date, "EndDate" => end_date
    }
  end

  def json_attributes
    {}
  end

  def json_methods
    {
      :category => nil,
      :description => nil,
      :account_sid => nil,
      :start_date => nil,
      :end_date => nil,
      :count => nil,
      :count_unit => nil,
      :usage => nil,
      :usage_unit => nil,
      :price => nil,
      :price_unit => nil,
      :api_version => nil,
      :uri => nil,
      :subresource_uris => nil
    }
  end
end
