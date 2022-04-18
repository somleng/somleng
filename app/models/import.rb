class Import < ApplicationRecord
  extend Enumerize
  enumerize :resource_type, in: %w[PhoneNumber]

  belongs_to :user
  belongs_to :carrier

  has_one_attached :file

  validates :file, presence: true
end
