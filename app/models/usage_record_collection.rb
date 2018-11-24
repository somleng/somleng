class UsageRecordCollection
  delegate :serializer_class, to: :class

  attr_accessor :account, :filter_params

  DEFAULT_START_DATE = Date.new(2010, 3, 27) # same as Twilio
  DEFAULT_CATEGORIES = ["calls", "calls-inbound", "calls-outbound"].freeze

  def initialize(options = {})
    self.account = options.fetch(:account)
    self.filter_params = options.fetch(:filter_params).transform_keys { |k| k.to_s.underscore.to_sym }
  end

  def usage_records
    Array(filter_params.fetch(:category) { DEFAULT_CATEGORIES }).map do |category_name|
      usage_record_type = "UsageRecord::#{category_name.underscore.camelize}".constantize
      usage_record_type.new(category_name, self)
    end
  end

  def start_date
    filter_params.fetch(:start_date) { DEFAULT_START_DATE }
  end

  def end_date
    filter_params.fetch(:end_date) { Date.today }
  end

  def self.serializer_class
    UsageRecordCollectionSerializer
  end
end
