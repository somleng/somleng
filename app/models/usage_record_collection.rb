class UsageRecordCollection
  delegate :serializer_class, to: :class

  attr_accessor :account, :filter_params

  DEFAULT_START_DATE = Date.new(2010, 3, 27) # same as Twilio
  DEFAULT_CATEGORIES = ["calls"].freeze

  CATEGORY_MAPPINGS = {
    "calls" => {
      class: PhoneCall,
      scoped_collection: proc { |phone_calls, collection|
        phone_calls.joins(:call_data_record)
                   .merge(CallDataRecord.billable)
                   .merge(
                     CallDataRecord.between_dates(
                       collection.start_date,
                       collection.end_date,
                       date_column: :start_time
                     )
                   )
      },
      attributes: {
        description: "Voice Minutes",
        usage_unit: "minutes",
        count_unit: "calls",
        price: proc { |phone_calls| Money.new(phone_calls.sum(:price_microunits), "USD6").exchange_to("USD") },
        usage: proc { |phone_calls| phone_calls.sum("((\"#{CallDataRecord.table_name}\".\"bill_sec\" - 1) / 60) + 1") },
        count: proc { |phone_calls| phone_calls.count }
      }
    }
  }.freeze

  ATTRIBUTE_MAPPINGS = {
    Category: :category,
    StartDate: :start_date,
    EndDate: :end_date
  }.freeze

  def initialize(options = {})
    self.account = options.fetch(:account)
    self.filter_params = options.fetch(:filter_params).transform_keys { |k| ATTRIBUTE_MAPPINGS.fetch(k) }
  end

  def usage_records
    Array(filter_params.fetch(:category) { DEFAULT_CATEGORIES }).map do |category|
      category_settings = CATEGORY_MAPPINGS.fetch(category)
      default_collection = category_settings.fetch(:class).all
      scoped_collection = category_settings.fetch(:scoped_collection).call(default_collection, self)
      collection = apply_default_scope(scoped_collection)
      UsageRecord.new(
        category: category, collection: collection,
        start_date: start_date, end_date: end_date,
        account: account, **category_settings.fetch(:attributes)
      )
    end
  end

  def self.serializer_class
    UsageRecordCollectionSerializer
  end

  def start_date
    filter_params.fetch(:start_date) { DEFAULT_START_DATE }
  end

  def end_date
    filter_params.fetch(:end_date) { Date.today }
  end

  private

  def apply_default_scope(scope)
    scope.where(account: account)
  end

  UsageRecord = ImmutableStruct.new(
    :collection, :category, :description, :usage_unit, :price,
    :count_unit, :start_date, :end_date, :account, :usage, :count
  ) do

    def price
      @price.call(collection)
    end

    def usage
      @usage.call(collection)
    end

    def count
      @count.call(collection)
    end
  end
end
