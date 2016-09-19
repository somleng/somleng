require "twilreapi/worker/job/outbound_call_job"

class PhoneCall < ApplicationRecord
  include TwilioApiResource
  include TwilioUrlLogic

  belongs_to :incoming_phone_number
  before_validation :normalize_phone_numbers

  validates :from, :status, :presence => true
  validates :to, :presence => true, :phony_plausible => true
  validates :external_id, :uniqueness => true, :strict => true, :allow_nil => true
  validates :external_id, :incoming_phone_number, :presence => true, :if => :inbound?

  attr_accessor :inbound

  alias_attribute :"To", :to
  alias_attribute :"From", :from
  alias_attribute :"ExternalSid", :external_id

  delegate :auth_token, :to => :account, :prefix => true
  delegate :routing_instructions, :to => :active_call_router

  delegate :voice_url, :voice_method,
           :status_callback_url, :status_callback_method,
           :account,
           :to => :incoming_phone_number, :prefix => true, :allow_nil => true

  include AASM

  aasm :column => :status do
    state :queued, :initial => true
    state :initiated
    state :ringing
    state :answered
    state :completed
    state :canceled

    event :initiate do
      transitions :from => :queued, :to => :initiated, :guard => :external_id?
    end

    event :cancel do
      transitions :from => :queued, :to => :canceled
    end
  end

  def initiate_or_cancel!
    external_id? ? initiate! : cancel!
  end

  def serializable_hash(options = nil)
    options ||= {}
    super(
      {
        :only => [:to, :from, :status]
      }.merge(options)
    )
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
      :methods => internal_json_methods.keys
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
      initiate
    end
    save
  end

  private

  def inbound?
    !!inbound
  end

  def normalize_phone_numbers
    self.to = PhonyRails.normalize_number(to)
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

  def job_adapter
    @job_adapter ||= JobAdapter.new(:outbound_call_worker)
  end

  def active_call_router
    @active_call_router ||= ActiveCallRouterAdapter.instance(from, to)
  end
end
