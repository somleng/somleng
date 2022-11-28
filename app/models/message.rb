class Message < ApplicationRecord
  include AASM
  include HasBeneficiary
  extend Enumerize

  belongs_to :carrier
  belongs_to :account
  belongs_to :sms_gateway, optional: true
  belongs_to :phone_number, optional: true

  enumerize :direction, in: %i[inbound outbound_api outbound_call outbound_reply],
                        predicates: true, scope: :shallow

  enumerize :encoding, in: %w[GSM UCS2]
  enumerize :status_callback_method, in: %w[POST GET]

  aasm column: :status do
    state :queued, initial: true
    state :initiated
    state :sent
    state :failed
    state :received

    event :mark_as_initiated do
      transitions from: :queued, to: :initiated
    end

    event :mark_as_sent do
      transitions from: :initiated, to: :sent
    end

    event :mark_as_failed do
      transitions from: :initiated, to: :failed
    end
  end

  def outbound?
    direction.in?(%w[outbound_api outbound_call outbound_reply])
  end

  def complete?
    status.in?(%w[sent failed received])
  end
end
