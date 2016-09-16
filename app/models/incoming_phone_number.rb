class IncomingPhoneNumber < ApplicationRecord
  include TwilioApiResource
  include TwilioUrlLogic

  validates :phone_number,
            :uniqueness => {:case_sensitive => false, :strict => true},
            :phony_plausible => true,
            :presence => true

  phony_normalize :phone_number

  def serializable_hash(options = nil)
    options ||= {}
    super(
      {
        :only => [:phone_number]
      }.merge(options)
    )
  end

  def uri
    Rails.application.routes.url_helpers.api_twilio_account_incoming_phone_number_path(account, id)
  end
end
