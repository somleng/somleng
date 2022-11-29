class MessagingService < ApplicationRecord
  extend Enumerize

  belongs_to :account
  belongs_to :carrier
  has_many :senders, class_name: "MessagingServiceSender", foreign_key: :messaging_service_id
  has_many :phone_numbers, through: :senders

  enumerize :inbound_request_method, in: %w[POST GET]
  enumerize :status_callback_method, in: %w[POST GET]
end
