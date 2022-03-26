class Recording < ApplicationRecord
  extend Enumerize
  include AASM

  has_one_attached :file
  has_one_attached :mp3_file

  belongs_to :phone_call
  belongs_to :account

  enumerize :status_callback_method, in: %w[POST GET]

  aasm column: :status do
    state :in_progress, initial: true
    state :completed

    event :complete do
      transitions from: :in_progress, to: :completed
    end
  end
end
