class Usage::Record::Collection
  include ActiveModel::Serializers::JSON
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  include TwilioJson

  CATEGORIES = [
    "calls", "calls-inbound", "calls-outbound"
  ]

  DEFAULT_PAGE_SIZE = 50

  class DateValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value || !options[:allow_nil]
        begin
          parsed_date = Date.parse(value.to_s)
          record.errors.add(attribute, :invalid) if options[:on_or_after] && record.public_send(options[:on_or_after]) && parsed_date < record.public_send(options[:on_or_after])
        rescue ArgumentError => e
          record.errors.add(attribute, :invalid)
        end
      end
    end
  end

  attr_accessor :account, :category, :start_date, :end_date

  validates :account,    :presence => true
  validates :category,   :inclusion => { :in => CATEGORIES, :allow_nil => true }
  validates :start_date, :date => {:allow_nil => true}
  validates :end_date,   :date => {:on_or_after => :start_date, :allow_nil => true}

  before_validation :parse_dates

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
      usage_record_calls,
      usage_record_calls_inbound,
      usage_record_calls_outbound
    ]
  end

  def usage_record_calls
    @usage_record_calls ||= Usage::Record::Calls.new(
      :account => account, :start_date => start_date, :end_date => end_date
    )
  end

  def usage_record_calls_inbound
    @usage_record_calls_inbound ||= Usage::Record::CallsInbound.new(
      :account => account, :start_date => start_date, :end_date => end_date
    )
  end

  def usage_record_calls_outbound
    @usage_record_calls_outbound ||= Usage::Record::CallsOutbound.new(
      :account => account, :start_date => start_date, :end_date => end_date
    )
  end

  def first_page_uri
    uri
  end

  def previous_page_uri
  end

  def next_page_uri
  end

  def uri
    Rails.application.routes.url_helpers.api_twilio_account_usage_records_path(account, uri_query_params)
  end

  def page_size
    DEFAULT_PAGE_SIZE
  end

  def page
    0
  end

  def end
    0
  end

  def start
    0
  end

  private

  def uri_query_params
    {"Category" => category, "StartDate" => start_date, "EndDate" => end_date, :page => page}
  end

  def parse_dates
    parsed_start_date = parse_date(start_date)
    parsed_end_date = parse_date(end_date)
    self.start_date = parsed_start_date if parsed_start_date
    self.end_date = parsed_end_date if parsed_end_date
  end

  def parse_date(date_string)
    Date.parse(date_string) rescue nil
  end

  def json_attributes
    {}
  end

  def json_methods
    {
      :usage_records => nil,
      :first_page_uri => nil,
      :end => nil,
      :previous_page_uri => nil,
      :next_page_uri => nil,
      :page => nil,
      :page_size => nil,
      :start => nil,
      :uri => nil,
    }
  end
end
