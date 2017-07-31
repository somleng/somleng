class CallDataRecord < ApplicationRecord
  INBOUND_DIRECTION  = "inbound"
  OUTBOUND_DIRECTION = "outbound"
  DEFAULT_PRICE_STORE_CURRENCY = "USD6"

  DIRECTIONS = [INBOUND_DIRECTION, OUTBOUND_DIRECTION]

  attachment :file, :content_type => ["application/json"]

  belongs_to :phone_call

  validates :file, :presence => true

  validates :duration_sec,
            :bill_sec,
            :presence => true,
            :numericality => { :greater_than_or_equal_to => 0 }

  validates :direction, :presence => true, :inclusion => { :in => DIRECTIONS }
  validates :hangup_cause, :start_time, :end_time, :presence => true

  monetize :price_microunits,
           :as => :price,
           :numericality => {
             :greater_than_or_equal_to => 0,
           }

  delegate :answered?, :not_answered?, :busy?, :to => :completed_event

  class Query
    attr_accessor :scope, :arel_table

    def initialize(options = {})
      self.scope = options[:scope] || CallDataRecord.all
      self.arel_table = CallDataRecord.arel_table
    end

    # Scopes

    def inbound
      scope.merge(CallDataRecord.where(:direction => INBOUND_DIRECTION))
    end

    def outbound
      scope.merge(CallDataRecord.where(:direction => OUTBOUND_DIRECTION))
    end

    def billable
      scope.merge(CallDataRecord.where(arel_table[:bill_sec].gt(0)))
    end

    def between_dates(start_date, end_date)
      scope.merge(on_or_after_date(start_date)).merge(on_or_before_date(end_date))
    end

    # Aggregate functions

    def bill_minutes
      scope.billable.sum("((\"#{CallDataRecord.table_name}\".\"bill_sec\" - 1) / 60) + 1")
    end

    def total_price_in_usd
      total_price_in_money.exchange_to("USD")
    end

    private

    def cast_as_date(column_name)
      Arel::Nodes::NamedFunction.new('CAST', [arel_table[column_name].as('DATE')])
    end

    def on_or_after_date(date)
      date ? CallDataRecord.where(cast_as_date(:start_time).gteq(date)) : CallDataRecord.all
    end

    def on_or_before_date(date)
      date ? CallDataRecord.where(cast_as_date(:start_time).lteq(date)) : CallDataRecord.all
    end

    def total_price_in_microunits
      scope.sum(:price_microunits)
    end

    def total_price_in_money
      Money.new(total_price_in_microunits, DEFAULT_PRICE_STORE_CURRENCY)
    end
  end

  def self.outbound
    query.outbound
  end

  def self.inbound
    query.inbound
  end

  def self.billable
    query.billable
  end

  def self.between_dates(*args)
    query.between_dates(*args)
  end

  def self.bill_minutes
    query.bill_minutes
  end

  def self.total_price_in_usd
    query.total_price_in_usd
  end

  def self.query
    Query.new
  end

  def completed_event
    @completed_event ||= build_completed_event
  end

  private

  def build_completed_event
    completed_event = PhoneCallEvent::Completed.new
    completed_event.sip_term_status = sip_term_status
    completed_event.answer_time = answer_time
    completed_event
  end
end
