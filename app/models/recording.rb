class Recording < ApplicationRecord
  TWILIO_STATUS_MAPPINGS = {
    "initiated" => "processing",
    "waiting_for_file" => "processing",
    "processing" => "processing",
    "completed" => "completed"
  }

  TWIML_SOURCE = "RecordVerb"

  include TwilioApiResource

  belongs_to :phone_call
  has_many :phone_call_events,      :class_name => "PhoneCallEvent::Base"
  has_many :aws_sns_notifications,  :class_name => "AwsSnsMessage::Notification"
  has_one  :currently_recording_phone_call, :class_name => "PhoneCall"

  validates :status, :presence => true
  validates :original_file_id, :uniqueness => true

  attachment :file, :content_type => ["audio/wav", "audio/x-wav"]

  delegate :account, :to => :phone_call
  delegate :account_sid, :to => :phone_call

  include AASM

  aasm :column => :status, :whiny_transitions => false do
    state :initiated, :initial => true
    state :waiting_for_file
    state :failed
    state :processing
    state :completed

    event :wait_for_file do
      transitions :from => :initiated, :to => :waiting_for_file, :guard => :original_file_id?
      transitions :from => :initiated, :to => :failed
    end

    event :process do
      transitions :from => :waiting_for_file, :to => :processing
    end

    event :complete do
      transitions :from => :processing, :to => :completed
    end
  end

  def twilio_status
    TWILIO_STATUS_MAPPINGS[status]
  end

  def uri
    Rails.application.routes.url_helpers.api_twilio_account_recording_path(account, id)
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

  def price
  end

  def price_unit
  end

  def source
    TWIML_SOURCE
  end

  def channels
    1
  end

  private

  def json_attributes
    super.merge(
      :status => nil,
      :duration => nil
    )
  end

  def json_methods
    super.merge(
      :call_sid => nil,
      :price => nil,
      :price_unit => nil,
      :source => nil,
      :channels => nil
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
