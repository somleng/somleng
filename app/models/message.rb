class Message < ApplicationRecord
  include AASM
  include HasBeneficiary
  extend Enumerize

  belongs_to :carrier
  belongs_to :account
  belongs_to :sms_gateway, optional: true
  belongs_to :phone_number, optional: true
  belongs_to :messaging_service, optional: true
  has_one :interaction

  enumerize :direction, in: %i[inbound outbound_api outbound_call outbound_reply],
                        predicates: true, scope: :shallow

  enumerize :encoding, in: %w[GSM UCS2]

  delegate :fire!, to: :aasm

  aasm column: :status, timestamps: true do
    state :accepted
    state :queued
    state :sending
    state :sent
    state :failed
    state :received
    state :canceled
    state :scheduled

    event :mark_as_sending do
      transitions from: :queued, to: :sending
    end

    event :mark_as_sent do
      transitions from: :sending, to: :sent
    end

    event :mark_as_failed do
      transitions from: :sending, to: :failed
    end

    event :cancel do
      transitions from: :scheduled, to: :canceled
    end
  end

  def outbound?
    direction.in?(%w[outbound_api outbound_call outbound_reply])
  end

  def complete?
    status.in?(%w[sent failed received])
  end

  def validity_period_expired?
    return false if validity_period.blank?

    (created_at + validity_period.seconds).past?
  end
end
