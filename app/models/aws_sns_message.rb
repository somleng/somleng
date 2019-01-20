class AwsSnsMessage < ApplicationRecord
  extend Enumerize

  self.inheritance_column = :_type_disabled

  belongs_to :recording, optional: true

  enumerize :type, in: %i[subscription_confirmation notification unsubscribe_confirmation]

  def payload_message
    payload.fetch("Message")
  end
end
