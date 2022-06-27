class ErrorLog < ApplicationRecord
  belongs_to :carrier, optional: true
  belongs_to :account, optional: true

  validates :error_message, presence: true
end
