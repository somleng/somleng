class MessagingService < ApplicationRecord
  extend Enumerize

  belongs_to :account
  belongs_to :carrier
  has_many :incoming_phone_numbers
  has_many :messages
  has_many :messaging_service_alphanumeric_sender_ids
  has_many :alphanumeric_sender_ids, through: :messaging_service_alphanumeric_sender_ids

  enumerize :inbound_request_method, in: %w[POST GET]

  enumerize :inbound_message_behavior,
            in: %i[defer_to_sender drop webhook]
end
