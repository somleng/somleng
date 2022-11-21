class Message < ApplicationRecord
  include AASM
  include HasBeneficiary
  extend Enumerize

  belongs_to :carrier
  belongs_to :account
  belongs_to :sms_gateway, optional: true
  belongs_to :phone_number, optional: true

  enumerize :direction, in: %i[inbound outbound], predicates: true, scope: :shallow
  enumerize :status_callback_method, in: %w[POST GET]

  aasm column: :status do
    state :queued, initial: true
    state :initiated
    state :sent
    state :failed

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
end
