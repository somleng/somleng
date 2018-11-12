# frozen_string_literal: true

class Recording < ApplicationRecord
  TWILIO_STATUS_MAPPINGS = {
    "initiated" => "processing",
    "waiting_for_file" => "processing",
    "processing" => "processing",
    "completed" => "completed"
  }.freeze

  TWIML_SOURCE = "RecordVerb"

  include TwilioApiResource
  include Wisper::Publisher

  belongs_to :phone_call
  has_many :phone_call_events,      class_name: "PhoneCallEvent::Base"
  has_many :aws_sns_notifications,  class_name: "AwsSnsMessage::Notification"
  has_one  :currently_recording_phone_call, class_name: "PhoneCall"

  after_commit :publish_status_change

  validates :status, presence: true
  validates :original_file_id, uniqueness: { allow_nil: true }

  validates :status_callback_url,
            url: {
              no_local: true, allow_nil: true,
              if: :validate_status_callback_url?
            }

  attachment :file, content_type: ["audio/wav", "audio/x-wav"]

  delegate :account, to: :phone_call

  delegate :auth_token,
           to: :account,
           prefix: true

  delegate :account_sid, to: :phone_call

  attr_accessor :validate_status_callback_url

  include AASM

  aasm column: :status, whiny_transitions: false do
    state :initiated, initial: true
    state :waiting_for_file
    state :failed
    state :processing
    state :completed

    event :wait_for_file do
      transitions from: :initiated, to: :waiting_for_file, guard: :original_file_id?
      transitions from: :initiated, to: :failed
    end

    event :process do
      transitions from: :waiting_for_file, to: :processing
    end

    event :complete do
      transitions from: :processing, to: :completed
    end
  end

  def twilio_status
    TWILIO_STATUS_MAPPINGS[status]
  end

  def status_callback_url
    twiml_instructions["recordingStatusCallback"]
  end

  def status_callback_method
    twiml_instructions["recordingStatusCallbackMethod"]
  end

  def validate_status_callback_url?
    !!validate_status_callback_url
  end

  def uri
    path_or_url(:path)
  end

  def url
    path_or_url(:url, host: Rails.configuration.app_settings.fetch("default_url_host"))
  end

  def to_wav
    [file_filename, file]
  end

  def call_sid
    phone_call_id
  end

  def duration_seconds
    duration.to_i / 1000
  end

  def price; end

  def price_unit; end

  def source
    TWIML_SOURCE
  end

  def channels
    1
  end

  private

  def publish_status_change
    broadcast(:"recording_#{previous_changes[:status].last}", self) if previous_changes.key?(:status) && previous_changes[:status].first != previous_changes[:status].last
  end

  def path_or_url(type, options = {})
    Rails.application.routes.url_helpers.send("api_twilio_account_recording_#{type}", account, id, { protocol: "https" }.merge(options))
  end

  def json_attributes
    super.merge(
      status: nil,
      duration: nil
    )
  end

  def json_methods
    super.merge(
      call_sid: nil,
      price: nil,
      price_unit: nil,
      source: nil,
      channels: nil
    )
  end

  def read_attribute_for_serialization(key)
    method_to_serialize = attributes_for_serialization[key]
    method_to_serialize && send(method_to_serialize) || super
  end

  def attributes_for_serialization
    {
      "status" => :twilio_status,
      "duration" => :duration_seconds
    }
  end
end
