class PhoneCall < ApplicationRecord
  extend Enumerize

  enumerize :voice_method, in: %w[POST GET]
  enumerize :status_callback_method, in: %w[POST GET]

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

  belongs_to :account
  belongs_to :incoming_phone_number, optional: true

  has_one    :call_data_record
  has_many   :phone_call_events, class_name: "PhoneCallEvent::Base"

  before_validation :normalize_data

  validates :from, :status, presence: true

  validates :to,
            presence: true,
            phony_plausible: { unless: :incoming_phone_number, on: :create }

  validates :external_id, uniqueness: true, strict: true, allow_nil: true
  validates :external_id, presence: true, if: :incoming_phone_number

  alias_attribute :To, :to
  alias_attribute :From, :from
  alias_attribute :ExternalSid, :external_id
  alias_attribute :Variables, :variables

  delegate :auth_token, to: :account, prefix: true
  delegate :routing_instructions, to: :active_call_router
  delegate :sid, to: :account, prefix: true

  include AASM

  aasm column: :status do
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

    event :complete do
      transitions from: %i[initiated ringing answered], to: :completed
    end

    event :mark_as_not_answered do
      transitions from: %i[initiated ringing], to: :not_answered
    end

    event :mark_as_busy do
      transitions from: %i[initiated ringing], to: :busy
    end

    event :fail do
      transitions from: %i[initiated ringing], to: :failed
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

  def uri
    Rails.application.routes.url_helpers.api_twilio_account_call_path(account, id)
  end

  def annotation; end

  def answered_by; end

  def caller_name; end

  def direction
    incoming_phone_number.present? ? "inbound" : "outbound"
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
    if recordings.any?
      uris["recordings"] = Rails.application.routes.url_helpers.api_twilio_account_call_recordings_path(account_id, id)
    end
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

    account.settings.slice("source_matcher").symbolize_keys
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
