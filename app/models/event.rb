class Event < ApplicationRecord
  self.inheritance_column = :_type_disabled

  extend Enumerize

  TYPES = %i[
    phone_call.completed
    message.sent
    message.delivered
  ].freeze

  belongs_to :carrier
  belongs_to :phone_call, optional: true
  belongs_to :message, optional: true

  has_many :webhook_request_logs

  enumerize :type, in: TYPES

  def eventable=(eventable)
    case eventable
    when PhoneCall
      self.phone_call = eventable
    when Message
      self.message = eventable
    end
  end
end
