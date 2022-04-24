require "administrate/custom_dashboard"

class StatisticDashboard < Administrate::CustomDashboard
  resource "Statistics"

  class Filter
    TIME_FORMATS = {
      day: "%d %B %Y",
      month: "%B %Y",
      year: "%Y"
    }.freeze

    attr_reader :name, :reference_time, :time_period, :column

    def initialize(name:, reference_time:, time_period:, column: :created_at)
      @name = name
      @reference_time = reference_time
      @time_period = time_period
      @column = column
    end

    def apply(scope)
      scope.where(column => start_time..end_time)
    end

    def to_s
      reference_time.strftime(TIME_FORMATS.fetch(time_period))
    end

    private

    def start_time
      reference_time.public_send("beginning_of_#{time_period}")
    end

    def end_time
      reference_time.public_send("end_of_#{time_period}")
    end
  end

  class AllFilter < Filter
    def initialize(name:)
      super(name: name, reference_time: nil, time_period: nil)
    end

    def apply(scope)
      scope
    end

    def to_s
      name.to_s.titleize
    end
  end

  DEFAULT_FILTER = Filter.new(name: :today, reference_time: Time.current, time_period: :day)

  FILTERS = [
    AllFilter.new(name: :all_time),
    DEFAULT_FILTER,
    Filter.new(name: :yesterday, reference_time: 1.day.ago, time_period: :day),
    Filter.new(name: :this_month, reference_time: Time.current, time_period: :month),
    Filter.new(name: :last_month, reference_time: 1.month.ago, time_period: :month),
    Filter.new(name: :this_year, reference_time: Time.current, time_period: :year),
    Filter.new(name: :last_year, reference_time: 1.year.ago, time_period: :year)
  ]

  (2..31).each do |i|
    FILTERS << Filter.new(name: :"#{i}_days_ago", reference_time: i.days.ago, time_period: :day)
  end

  (2..12).each do |i|
    FILTERS << Filter.new(name: :"#{i}_months_ago", reference_time: i.months.ago, time_period: :month)
  end

  (2..10).each do |i|
    FILTERS << Filter.new(name: :"#{i}_years_ago", reference_time: i.years.ago, time_period: :year)
  end

  FILTERS.freeze

  attr_reader :filter

  def initialize(filter_name = nil)
    super()
    @filter = FILTERS.find(-> { DEFAULT_FILTER }) { |f| f.name == filter_name.to_s.to_sym }
  end

  def interactions_count
    interactions.count
  end

  def beneficiaries_count
    interactions.select(:beneficiary_fingerprint).distinct.count
  end

  def beneficiary_countries_count
    beneficiary_countries.count
  end

  def beneficiary_country_names
    beneficiary_countries.map { |interaction| interaction.beneficiary_country.iso_short_name }
  end

  def carriers_count
    carriers.count
  end

  def carrier_country_names
    carrier_countries.map { |carrier| carrier.country.iso_short_name }
  end

  def carrier_countries_count
    carrier_countries.count
  end

  def accounts_count
    accounts.count
  end

  private

  def interactions
    apply_filters(Interaction.all)
  end

  def beneficiary_countries
    interactions.where.not(beneficiary_country_code: nil).select(:beneficiary_country_code).distinct
  end

  def carrier_countries
    carriers.select(:country_code).distinct
  end

  def carriers
    apply_filters(Carrier.all)
  end

  def accounts
    apply_filters(Account.all)
  end

  def apply_filters(scope)
    filter.apply(scope)
  end
end
