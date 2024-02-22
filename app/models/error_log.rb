class ErrorLog < ApplicationRecord
  belongs_to :carrier, optional: true
  belongs_to :account, optional: true
  has_many :notifications, class_name: "ErrorLogNotification"

  validates :error_message, presence: true
end
