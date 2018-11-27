class IncomingPhoneNumber < ApplicationRecord
  include TwilioUrlLogic

  belongs_to :account
  has_many :phone_calls

  validates :phone_number,
            :uniqueness => {:case_sensitive => false, :strict => true},
            :presence => true

  phony_normalize :phone_number

  delegate :sid, :to => :account, :prefix => true

  def serializable_hash(options = nil)
    options ||= {}
    super(
      {
        :only => [:phone_number, :twilio_request_phone_number]
      }.merge(options)
    )
  end

  def uri
    Rails.application.routes.url_helpers.api_twilio_account_incoming_phone_number_path(account, id)
  end
end
