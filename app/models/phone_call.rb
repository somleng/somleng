require "twilreapi/worker/job/outbound_call_job"

class PhoneCall < ApplicationRecord
  TWILIO_CALL_DIRECTIONS = {
    "inbound" => "inbound",
    "outbound" => "outbound-api"
  }

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
  }

  include TwilioApiResource
  include TwilioUrlLogic

  belongs_to :incoming_phone_number
  has_one    :call_data_record
  has_many   :phone_call_events, :class_name => "PhoneCallEvent::Base"

  before_validation :normalize_phone_numbers

  validates :from, :status, :presence => true
  validates :to,
            :presence => true, :phony_plausible => { :unless => :inbound? }
  validates :external_id, :uniqueness => true, :strict => true, :allow_nil => true
  validates :external_id, :incoming_phone_number, :presence => true, :if => :inbound?

  attr_accessor :inbound, :twilio_request_to, :completed_event

  alias_attribute :"To", :to
  alias_attribute :"From", :from
  alias_attribute :"ExternalSid", :external_id

  delegate :auth_token, :to => :account, :prefix => true
  delegate :routing_instructions, :to => :active_call_router

  delegate :voice_url, :voice_method,
           :status_callback_url, :status_callback_method,
           :account, :sid,
           :twilio_request_phone_number,
           :to => :incoming_phone_number, :prefix => true, :allow_nil => true

  delegate :bill_sec,
           :direction,
           :answer_time,
           :end_time,
           :answered?,
           :not_answered?,
           :busy?,
           :to => :call_data_record,
           :prefix => true,
           :allow_nil => true

  delegate :answered?, :not_answered?, :busy?,
           :to => :completed_event,
           :prefix => true,
           :allow_nil => true

  include AASM

  aasm :column => :status do
    state :queued, :initial => true
    state :initiated
    state :ringing
    state :answered
    state :busy
    state :failed
    state :not_answered
    state :completed
    state :canceled

    event :initiate do
      transitions :from => :queued, :to => :initiated, :guard => :external_id?
    end

    event :cancel do
      transitions :from => :queued, :to => :canceled
    end

    event :ring do
      transitions :from => :initiated, :to => :ringing
    end

    event :answer do
      transitions :from => [:initiated, :ringing], :to => :answered
    end

    event :complete do
      transitions :from => :answered,
                  :to => :completed

      transitions :from => [:initiated, :ringing],
                  :to => :completed,
                  :if => :phone_call_event_answered?

      transitions :from => [:initiated, :ringing],
                  :to => :not_answered,
                  :if => :phone_call_event_not_answered?

      transitions :from => [:initiated, :ringing],
                  :to => :busy,
                  :if => :phone_call_event_busy?

      transitions :from => [:initiated, :ringing],
                  :to => :failed
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
    CallDataRecord::Query.new(:scope => joins(:call_data_record))
  end

  def self.execute_cdr_query
    joins(:call_data_record).merge(CallDataRecord)
  end

  def initiate_or_cancel!
    external_id? ? initiate! : cancel!
  end

  def to_internal_outbound_call_json
    to_json(
      :only => internal_json_attributes.keys,
      :methods => internal_json_methods.merge(:routing_instructions => nil).keys
    )
  end

  def to_internal_inbound_call_json
    to_json(
      :only => internal_json_attributes.keys,
      :methods => internal_json_methods.merge(:twilio_request_to => nil).keys
    )
  end

  def uri
    Rails.application.routes.url_helpers.api_twilio_account_call_path(account, id)
  end

  def enqueue_outbound_call!
    job_adapter.perform_later(job_adapter.passthrough? ? to_internal_outbound_call_json : id)
  end

  def initiate_outbound_call!
    outbound_call_id = Twilreapi::Worker::Job::OutboundCallJob.new.perform(to_internal_outbound_call_json)
    self.external_id = outbound_call_id
    initiate_or_cancel!
  end

  def initiate_inbound_call
    self.inbound = true
    normalize_phone_numbers
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

  def annotation
  end

  def answered_by
  end

  def caller_name
  end

  def direction
    TWILIO_CALL_DIRECTIONS[call_data_record_direction || (incoming_phone_number.present? && "inbound") || "outbound"]
  end

  def duration
    call_data_record_bill_sec.to_s.presence
  end

  def end_time
    call_data_record_answer_time && call_data_record_end_time.rfc2822
  end

  def forwarded_from
  end

  def from_formatted
    format_number(from)
  end

  def group_sid
  end

  def parent_call_sid
  end

  def phone_number_sid
    incoming_phone_number_sid
  end

  def price
  end

  def price_unit
  end

  def start_time
    call_data_record_answer_time && call_data_record_answer_time.rfc2822
  end

  def subresource_uris
    {}
  end

  def to_formatted
    format_number(to)
  end

  def twilio_status
    TWILIO_CALL_STATUS_MAPPINGS[status]
  end

  private

  def phone_call_event_answered?
    completed_event_answered? || call_data_record_answered?
  end

  def phone_call_event_not_answered?
    completed_event_not_answered? || call_data_record_not_answered?
  end

  def phone_call_event_busy?
    completed_event_busy? || call_data_record_busy?
  end

  def inbound?
    !!inbound
  end

  def normalize_phone_numbers
    self.to = PhonyRails.normalize_number(to)
  end

  def json_attributes
    super.merge(
      :to => nil,
      :from => nil,
      :status => nil
    )
  end

  def json_methods
    super.merge(
      :annotation => nil,
      :answered_by => nil,
      :caller_name => nil,
      :direction => nil,
      :duration => nil,
      :end_time => nil,
      :forwarded_from => nil,
      :from_formatted => nil,
      :group_sid => nil,
      :parent_call_sid => nil,
      :phone_number_sid => nil,
      :price => nil,
      :price_unit => nil,
      :start_time => nil,
      :subresource_uris => nil,
      :to_formatted => nil
    )
  end

  def internal_json_methods
    {
      :sid => nil,
      :account_sid => nil,
      :account_auth_token => nil
    }
  end

  def internal_json_attributes
    {
      :voice_url => nil,
      :voice_method => nil,
      :status_callback_url => nil,
      :status_callback_method => nil,
      :to => nil,
      :from => nil
    }
  end

  def format_number(number)
    number && Phony.format(Phony.normalize(number), :format => :international)
  end

  def job_adapter
    @job_adapter ||= JobAdapter.new(:outbound_call_worker)
  end

  def active_call_router
    @active_call_router ||= ActiveCallRouterAdapter.instance(:phone_call => self)
  end

  def read_attribute_for_serialization(key)
    method_to_serialize = attributes_for_serialization[key]
    method_to_serialize && send(method_to_serialize) || super
  end

  def attributes_for_serialization
    {
      "status" => :twilio_status
    }
  end
end
