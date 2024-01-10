class VerificationService < ApplicationRecord
  belongs_to :carrier
  belongs_to :account

  has_many :verifications
end
