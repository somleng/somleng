class Import < ApplicationRecord
  belongs_to :user
  belongs_to :carrier

  has_one_attached :file
end
