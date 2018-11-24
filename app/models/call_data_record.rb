class CallDataRecord < ApplicationRecord
  include Wisper::Publisher

  INBOUND_DIRECTION  = "inbound".freeze
  OUTBOUND_DIRECTION = "outbound".freeze
  DEFAULT_PRICE_STORE_CURRENCY = "USD6".freeze

  DIRECTIONS = [INBOUND_DIRECTION, OUTBOUND_DIRECTION].freeze

  attachment :file, content_type: ["application/json"]

  belongs_to :phone_call

  validates :file, presence: true

  validates :duration_sec,
            :bill_sec,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :direction, presence: true, inclusion: { in: DIRECTIONS }
  validates :hangup_cause, :start_time, :end_time, presence: true

  monetize :price_microunits,
           as: :price,
           numericality: {
             greater_than_or_equal_to: 0
           }

  after_commit :publish_created, on: :create

  delegate :answered?, :not_answered?, :busy?, to: :completed_event

  def self.outbound
    where(direction: OUTBOUND_DIRECTION)
  end

  def self.inbound
    where(direction: INBOUND_DIRECTION)
  end

  def self.billable
    where(arel_table[:bill_sec].gt(0))
  end

  def completed_event
    @completed_event ||= build_completed_event
  end

  private

  def publish_created
    broadcast(:call_data_record_created, self)
  end

  def build_completed_event
    completed_event = PhoneCallEvent::Completed.new
    completed_event.sip_term_status = sip_term_status
    completed_event.answer_time = answer_time
    completed_event
  end
end
