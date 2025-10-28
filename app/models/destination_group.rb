class DestinationGroup < ApplicationRecord
  belongs_to :carrier
  has_many :prefixes, class_name: "DestinationPrefix", dependent: :destroy, autosave: true, inverse_of: :destination_group
  has_many :destination_tariffs
  has_many :tariffs, through: :destination_tariffs
end
