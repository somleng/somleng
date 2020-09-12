class CallDataRecord < ApplicationRecord
  extend Enumerize

  enumerize :direction, in: %i[inbound outbound]

  belongs_to :phone_call

  has_one_attached :file

  validates :file, presence: true
end
