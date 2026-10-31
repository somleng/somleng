class AlphanumericSenderID < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  belongs_to :account

  enumerize :approval_status,
            in: [ :pending_approval, :rejected, :approved ],
            default: :pending_approval,
            predicates: true,
            scope: :shallow

  validates :sender_id, presence: true, alphanumeric_sender_id_format: true
end
