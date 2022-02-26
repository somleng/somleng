class Recording < ApplicationRecord
  include AASM

  belongs_to :phone_call
  belongs_to :account

  aasm column: :status do
    state :in_progress, initial: true
    state :completed
  end
end
