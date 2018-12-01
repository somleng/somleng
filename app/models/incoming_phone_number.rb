class IncomingPhoneNumber < ApplicationRecord
  belongs_to :account
  has_many :phone_calls

  validates :phone_number,
            uniqueness: { case_sensitive: false, strict: true },
            presence: true
end
