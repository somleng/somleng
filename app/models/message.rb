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
    state :initiating
    state :initiated
    state :sent
    state :failed
  end
end
