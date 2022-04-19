class Import < ApplicationRecord
  extend Enumerize
  include AASM

  attr_accessor :error_line

  enumerize :resource_type, in: %w[PhoneNumber]

  belongs_to :user
  belongs_to :carrier

  has_one_attached :file

  validates :file, presence: true, attached: true, content_type: "text/csv"

  aasm column: :status do
    state :processing, initial: true
    state :failed
    state :completed

    event :complete do
      transitions from: :processing, to: :completed
    end

    event :fail do
      transitions from: :processing, to: :failed
    end
  end
end
