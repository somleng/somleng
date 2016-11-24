class CallDataRecord < ApplicationRecord
  INBOUND_DIRECTION  = "inbound"
  OUTBOUND_DIRECTION = "outbound"
  DEFAULT_PRICE_STORE_CURRENCY = "USD6"

  DIRECTIONS = [INBOUND_DIRECTION, OUTBOUND_DIRECTION]

  attachment :file, :content_type => ["application/json"]

  belongs_to :phone_call

  validates :phone_call, :file, :presence => true

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

  def enqueue_process!(cdr)
    job_adapter.perform_later(cdr)
  end

  def process(raw_cdr)
    cdr = CDR::Freeswitch.new(raw_cdr)
    self.phone_call = PhoneCall.find_by_external_id(cdr.uuid)
    self.file_content_type, self.file_filename, self.file = cdr.to_file
    self.hangup_cause = cdr.hangup_cause
    self.direction = cdr.direction
    self.duration_sec = cdr.duration_sec
    self.bill_sec = cdr.bill_sec
    self.start_time = parse_epoch(cdr.start_epoch)
    self.end_time = parse_epoch(cdr.end_epoch)
    self.answer_time = parse_epoch(cdr.answer_epoch)
    self.sip_term_status = cdr.sip_term_status
    self.price = calculate_price(cdr)
    save
  end

  class Query
    attr_accessor :scope, :active_record_class, :arel_table

    def initialize(scope, active_record_class)
      self.scope = scope
      self.active_record_class = active_record_class
      self.arel_table = active_record_class.arel_table
    end

    def total_price_in_usd
      total_price_in_money.exchange_to("USD")
    end

    def bill_minutes
      scope.billable.sum("((bill_sec - 1) / 60) + 1")
    end

    def outbound
      scope.where(:direction => OUTBOUND_DIRECTION)
    end

    def billable
      scope.where(arel_table[:bill_sec].gt(0))
    end

    def between_dates(start_date, end_date)
      scope.merge(on_or_after_date(start_date)).merge(on_or_before_date(end_date))
    end

    private

    def total_price_in_microunits
      scope.sum(:price_microunits)
    end

    def total_price_in_money
      Money.new(total_price_in_microunits, DEFAULT_PRICE_STORE_CURRENCY)
    end

    def on_or_after_date(date)
      date ? active_record_class.where(arel_table[:start_time].gteq(date)) : active_record_class.all
    end

    def on_or_before_date(date)
      date ? active_record_class.where(arel_table[:start_time].lteq(date)) : active_record_class.all
    end
  end

  def self.outbound
    query.outbound
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
    Query.new(all, self)
  end

  private

  def calculate_price(cdr)
    active_biller.options = {:cdr => cdr}
    self.price = Money.new(active_biller.calculate_price_in_micro_units, DEFAULT_PRICE_STORE_CURRENCY)
  end

  def active_biller
    @active_biller ||= ActiveBillerAdapter.instance
  end

  def parse_epoch(epoch)
    epoch = epoch.to_i
    Time.at(epoch) if epoch > 0
  end

  def job_adapter
    @job_adapter ||= JobAdapter.new(:call_data_record_worker)
  end
end
