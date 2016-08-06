class PhoneCall < ActiveRecord::Base
  DEFAULT_URL_METHOD = "POST"
  ALLOWED_URL_METHODS = [DEFAULT_URL_METHOD, "GET"]


  belongs_to :account
  validates :from, :voice_url, :status, :presence => true
  validates :to, :presence => true, :phony_plausible => true
  validates :voice_method, :presence => true, :inclusion => { :in => ALLOWED_URL_METHODS }

  phony_normalize :to

  before_validation :set_defaults, :normalize_methods, :on => :create

  alias_attribute :sid, :id
  alias_attribute :"To", :to
  alias_attribute :"From", :from
  alias_attribute :"Url", :voice_url
  alias_attribute :"Method", :voice_method
  alias_attribute :"StatusCallback", :status_callback_url
  alias_attribute :"StatusCallbackMethod", :status_callback_method

  delegate :sid, :to => :account, :prefix => true

  include AASM

  aasm :column => :status do
    state :queued, :initial => true
    state :initiated
    state :ringing
    state :answered
    state :completed

    event :initiate do
      transitions :from => :queued, :to => :initiated
    end
  end

  def serializable_hash(options = nil)
    options ||= {}
    super(
      {
        :only => [:to, :from, :status],
        :methods => [:sid, :account_sid, :uri, :date_created, :date_updated]
      }.merge(options)
    )
  end

  def date_created
    created_at.rfc2822
  end

  def date_updated
    updated_at.rfc2822
  end

  def uri
    Rails.application.routes.url_helpers.api_twilio_account_call_path(account, id)
  end

  def enqueue_outbound_call!
    JobAdapter.new(:outbound_call_worker).perform_later(to_json)
  end

  private

  def set_defaults
    self.voice_method ||= DEFAULT_URL_METHOD
  end

  def normalize_methods
    self.voice_method.upcase! if voice_method?
  end
end
