class CallDataRecord < ApplicationRecord
  extend Enumerize

  enumerize :direction, in: %i[inbound outbound]
  enumerize :call_leg, in: %i[A B], default: :A

  belongs_to :phone_call
  has_one_attached :file

  validates :file, :call_leg, presence: true
end
