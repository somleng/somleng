class Recording < ApplicationRecord
  include AASM

  has_one_attached :file

  belongs_to :phone_call
  belongs_to :account

  aasm column: :status do
    state :in_progress, initial: true
    state :completed

    event :complete do
      transitions from: :in_progress, to: :completed
    end
  end
end
