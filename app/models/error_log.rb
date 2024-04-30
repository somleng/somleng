class ErrorLog < ApplicationRecord
  self.inheritance_column = :_type_disabled

  extend Enumerize

  belongs_to :carrier, optional: true
  belongs_to :account, optional: true
  has_many :notifications, class_name: "ErrorLogNotification"

  enumerize :type, in: [ :inbound_message, :inbound_call, :sms_gateway_disconnect ]
  validates :error_message, presence: true
end
