class VerificationService < ApplicationRecord
  belongs_to :carrier
  belongs_to :account
end
