class MessagingService < ApplicationRecord
  extend Enumerize

  belongs_to :account
  belongs_to :carrier
  has_many :incoming_phone_numbers
  has_many :messages

  enumerize :inbound_request_method, in: %w[POST GET]

  enumerize :inbound_message_behavior,
            in: %i[defer_to_sender drop webhook]
end
