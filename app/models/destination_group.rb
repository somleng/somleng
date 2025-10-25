class DestinationGroup < ApplicationRecord
  belongs_to :carrier
  has_many :prefixes, class_name: "DestinationPrefix", dependent: :destroy, autosave: true, inverse_of: :destination_group
end
