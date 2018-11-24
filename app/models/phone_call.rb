class PhoneCall < ApplicationRecord
  include Wisper::Publisher

  belongs_to :account
  belongs_to :incoming_phone_number, optional: true
  belongs_to :recording, optional: true

  has_one    :call_data_record
  has_many   :phone_call_events, class_name: "PhoneCallEvent::Base"
  has_many   :recordings

  before_validation :normalize_phone_numbers

  validates :from, :status, presence: true

  validates :to,
            presence: true,
            phony_plausible: { unless: :initiating_inbound_call?, on: :create }

  validates :external_id, uniqueness: true, strict: true, allow_nil: true
  validates :external_id, :incoming_phone_number, presence: true, if: :initiating_inbound_call?

  attr_accessor :initiating_inbound_call, :completed_event, :twilio_request_to

  delegate :voice_url, :voice_method,
           :status_callback_url, :status_callback_method,
           :account, :sid,
           :twilio_request_phone_number,
           to: :incoming_phone_number, prefix: true, allow_nil: true

  delegate :bill_sec,
           :direction,
           :answer_time,
           :end_time,
           :answered?,
           :not_answered?,
           :busy?,
           to: :call_data_record,
           prefix: true,
           allow_nil: true

  delegate :answered?, :not_answered?, :busy?,
           to: :completed_event,
           prefix: true,
           allow_nil: true

  delegate :sid, to: :account, prefix: true

  include AASM

  aasm column: :status, whiny_transitions: false do
    state :queued, initial: true
    state :initiated
    state :ringing
    state :answered
    state :busy
    state :failed
    state :not_answered
    state :completed
    state :canceled

    event :initiate do
      transitions from: :queued, to: :initiated, guard: :has_external_id?
    end

    event :cancel do
      transitions from: :queued, to: :canceled
    end

    event :ring do
      transitions from: :initiated, to: :ringing
    end

    event :answer do
      transitions from: %i[initiated ringing], to: :answered
    end

    event :complete, after_commit: :publish_completed do
      transitions from: :answered,
                  to: :completed

      transitions from: %i[initiated ringing],
                  to: :completed,
                  if: :phone_call_event_answered?

      transitions from: %i[initiated ringing],
                  to: :not_answered,
                  if: :phone_call_event_not_answered?

      transitions from: %i[initiated ringing],
                  to: :busy,
                  if: :phone_call_event_busy?

      transitions from: %i[initiated ringing],
                  to: :failed
    end
  end

  def self.billable
    cdr_query.billable
  end

  def self.between_dates(*args)
    cdr_query.between_dates(*args)
  end

  def self.bill_minutes
    cdr_query.bill_minutes
  end

  def self.total_price_in_usd
    cdr_query.total_price_in_usd
  end

  def self.inbound
    cdr_query.inbound
  end

  def self.outbound
    cdr_query.outbound
  end

  def self.cdr_query
    CallDataRecord::Query.new(scope: joins(:call_data_record))
  end

  def self.execute_cdr_query
    joins(:call_data_record).merge(CallDataRecord)
  end

  def initiate_or_cancel!
    external_id? ? initiate! : cancel!
  end

  def to_internal_inbound_call_json
    to_json(
      only: internal_json_attributes.keys,
      methods: internal_json_methods.merge(
        twilio_request_to: nil
      ).keys
    )
  end

  def initiate_inbound_call
    self.initiating_inbound_call = true
    normalize_phone_numbers
    normalize_from
    if self.incoming_phone_number = IncomingPhoneNumber.find_by_phone_number(to)
      self.account = incoming_phone_number_account
      self.voice_url = incoming_phone_number_voice_url
      self.voice_method = incoming_phone_number_voice_method
      self.status_callback_url = incoming_phone_number_status_callback_url
      self.status_callback_method = incoming_phone_number_status_callback_method
      self.twilio_request_to = incoming_phone_number_twilio_request_phone_number
      initiate
    end
    save
  end

  private

  def publish_completed
    broadcast(:phone_call_completed, self)
  end

  def has_external_id?
    external_id?
  end

  def phone_call_event_answered?
    completed_event_answered? || call_data_record_answered?
  end

  def phone_call_event_not_answered?
    completed_event_not_answered? || call_data_record_not_answered?
  end

  def phone_call_event_busy?
    completed_event_busy? || call_data_record_busy?
  end

  def initiating_inbound_call?
    initiating_inbound_call.present?
  end

  def normalize_from
    normalized_from = PhonyRails.normalize_number(active_call_router.normalized_source)
    self.from = normalized_from if normalized_from
  end

  def normalize_phone_numbers
    self.to = PhonyRails.normalize_number(to)
  end
end
