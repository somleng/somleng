class PhoneCall < ApplicationRecord
  include Wisper::Publisher

  TWILIO_CALL_DIRECTIONS = {
    "inbound" => "inbound",
    "outbound" => "outbound-api"
  }.freeze

  TWILIO_CALL_STATUS_MAPPINGS = {
    "queued" => "queued",
    "initiated" => "queued",
    "ringing" => "ringing",
    "answered" => "in-progress",
    "busy" => "busy",
    "failed" => "failed",
    "not_answered" => "no-answer",
    "completed" => "completed",
    "canceled" => "canceled"
  }.freeze

  include TwilioApiResource
  include TwilioUrlLogic

  belongs_to :account
  belongs_to :incoming_phone_number, optional: true
  belongs_to :recording, optional: true

  has_one    :call_data_record
  has_many   :phone_call_events, class_name: "PhoneCallEvent::Base"
  has_many   :recordings

  before_validation :normalize_data

  validates :from, :status, presence: true

  validates :to,
            presence: true,
            phony_plausible: { unless: :incoming_phone_number, on: :create }

  validates :external_id, uniqueness: true, strict: true, allow_nil: true
  validates :external_id, presence: true, if: :incoming_phone_number

  attr_accessor :completed_event, :twilio_request_to

  alias_attribute :To, :to
  alias_attribute :From, :from
  alias_attribute :ExternalSid, :external_id
  alias_attribute :Variables, :variables

  delegate :auth_token, to: :account, prefix: true
  delegate :routing_instructions, to: :active_call_router
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
      transitions from: :queued, to: :initiated, guard: :external_id?
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

  def initiate_or_cancel!
    external_id? ? initiate! : cancel!
  end

  def to_internal_outbound_call_json
    to_json(
      only: internal_json_attributes.keys,
      methods: internal_json_methods.merge(routing_instructions: nil).keys
    )
  end

  def to_internal_inbound_call_json
    to_json(
      only: internal_json_attributes.keys,
      methods: internal_json_methods.merge(
        twilio_request_to: nil
      ).keys
    )
  end

  def uri
    Rails.application.routes.url_helpers.api_twilio_account_call_path(account, id)
  end

  def enqueue_outbound_call!
    OutboundCallJob.perform_later(id)
  end

  def initiate_inbound_call
    self.incoming_phone_number = IncomingPhoneNumber.find_by_phone_number(
      normalize_phone_number(to)
    )

    if incoming_phone_number.blank?
      errors.add(:incoming_phone_number, :blank)
      return false
    end

    self.account = incoming_phone_number.account
    self.voice_url = incoming_phone_number.voice_url
    self.voice_method = incoming_phone_number.voice_method
    self.status_callback_url = incoming_phone_number.status_callback_url
    self.status_callback_method = incoming_phone_number.status_callback_method
    self.twilio_request_to = incoming_phone_number.twilio_request_phone_number
    self.from = normalize_phone_number(active_call_router.normalized_source)
    initiate

    save
  end

  def annotation; end

  def answered_by; end

  def caller_name; end

  def direction
    direction_key = call_data_record&.direction
    direction_key ||= "inbound" if incoming_phone_number.present?
    direction_key ||= "outbound"
    TWILIO_CALL_DIRECTIONS.fetch(direction_key)
  end

  def duration
    call_data_record&.bill_sec&.to_s.presence
  end

  def end_time
    call_data_record&.end_time&.rfc2822
  end

  def forwarded_from; end

  def from_formatted
    format_number(from)
  end

  def group_sid; end

  def parent_call_sid; end

  def phone_number_sid
    incoming_phone_number&.id
  end

  def price; end

  def price_unit; end

  def start_time
    call_data_record&.answer_time&.rfc2822
  end

  def subresource_uris
    uris = {}
    uris["recordings"] = Rails.application.routes.url_helpers.api_twilio_account_call_recordings_path(account_id, id) if recordings.any?
    uris
  end

  def to_formatted
    format_number(to)
  end

  def twilio_status
    TWILIO_CALL_STATUS_MAPPINGS[status]
  end

  def active_call_router
    CallRouter.new(source: from, destination: to, **call_router_options)
  end

  private

  def call_router_options
    return {} if account.blank?

    account.settings.slice(
      "source_matcher",
      "trunk_prefix_replacement"
    ).symbolize_keys
  end

  def publish_completed
    broadcast(:phone_call_completed, self)
  end

  def phone_call_event_answered?
    completed_event&.answered? || call_data_record&.answered?
  end

  def phone_call_event_not_answered?
    completed_event&.not_answered? || call_data_record&.not_answered?
  end

  def phone_call_event_busy?
    completed_event&.busy? || call_data_record&.busy?
  end

  def json_attributes
    super.merge(
      to: nil,
      from: nil,
      status: nil
    )
  end

  def json_methods
    super.merge(
      annotation: nil,
      answered_by: nil,
      caller_name: nil,
      direction: nil,
      duration: nil,
      end_time: nil,
      forwarded_from: nil,
      from_formatted: nil,
      group_sid: nil,
      parent_call_sid: nil,
      phone_number_sid: nil,
      price: nil,
      price_unit: nil,
      start_time: nil,
      subresource_uris: nil,
      to_formatted: nil
    )
  end

  def internal_json_methods
    {
      sid: nil,
      account_sid: nil,
      account_auth_token: nil,
      direction: nil,
      api_version: nil
    }
  end

  def internal_json_attributes
    {
      voice_url: nil,
      voice_method: nil,
      to: nil,
      from: nil
    }
  end

  def normalize_data
    self.to = normalize_phone_number(to)
  end

  def normalize_phone_number(phone_number)
    PhonyRails.normalize_number(phone_number)
  end

  def format_number(number)
    normalized_number = safe_phony_normalize(number)
    (normalized_number && Phony.format(normalized_number, format: :international)) || number
  end

  def safe_phony_normalize(number)
    Phony.normalize(number)
  rescue StandardError
    nil
  end

  def read_attribute_for_serialization(key)
    method_to_serialize = attributes_for_serialization[key]
    method_to_serialize && send(method_to_serialize) || super
  end

  def attributes_for_serialization
    { "status" => :twilio_status }
  end
end
