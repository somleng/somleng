require "twilreapi/worker/job/outbound_call_job"

class PhoneCall < ApplicationRecord
  include TwilioApiResource
  include TwilioUrlLogic

  validates :from, :status, :presence => true
  validates :to, :presence => true, :phony_plausible => true
  validates :somleng_call_id, :uniqueness => true, :strict => true, :allow_nil => true

  phony_normalize :to

  alias_attribute :"To", :to
  alias_attribute :"From", :from

  delegate :auth_token, :to => :account, :prefix => true
  delegate :routing_instructions, :to => :active_call_router

  include AASM

  aasm :column => :status do
    state :queued, :initial => true
    state :initiated
    state :ringing
    state :answered
    state :completed
    state :canceled

    event :initiate do
      transitions :from => :queued, :to => :initiated, :guard => :somleng_call_id?
    end

    event :cancel do
      transitions :from => :queued, :to => :canceled
    end
  end

  def initiate_or_cancel!
    somleng_call_id? ? initiate! : cancel!
  end

  def serializable_hash(options = nil)
    options ||= {}
    super(
      {
        :only => [:to, :from, :status]
      }.merge(options)
    )
  end

  def to_somleng_json
    to_json(
      :only => [
        :voice_url, :voice_method, :status_callback_url, :status_callback_method, :to, :from
      ],
      :methods => [:sid, :account_sid, :account_auth_token, :routing_instructions]
    )
  end

  def uri
    Rails.application.routes.url_helpers.api_twilio_account_call_path(account, id)
  end

  def enqueue_outbound_call!
    job_adapter.perform_later(job_adapter.passthrough? ? to_somleng_json : id)
  end

  def initiate_outbound_call!
    outbound_call_id = Twilreapi::Worker::Job::OutboundCallJob.new.perform(to_somleng_json)
    self.somleng_call_id = outbound_call_id
    initiate_or_cancel!
  end

  private

  def job_adapter
    @job_adapter ||= JobAdapter.new(:outbound_call_worker)
  end

  def active_call_router
    @active_call_router ||= ActiveCallRouterAdapter.instance(from, to)
  end
end
