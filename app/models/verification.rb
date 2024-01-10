class Verification < ApplicationRecord
  include AASM
  extend Enumerize

  belongs_to :carrier
  belongs_to :account
  belongs_to :verification_service

  enumerize :channel, in: %i[sms call]

  delegate :may_fire_event?, :fire!, to: :aasm

  aasm column: :status, timestamps: true do
    state :pending, initial: true
    state :approved
    state :canceled

    event :approve do
      transitions from: :pending, to: :approved
    end

    event :cancel do
      transitions from: :pending, to: :canceled
    end
  end
end
