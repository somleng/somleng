class DestinationGroup < ApplicationRecord
  DEFAULT_CATCH_ALL_NAME = "Catch all"

  belongs_to :carrier
  has_many :prefixes, class_name: "DestinationPrefix", dependent: :destroy, autosave: true, inverse_of: :destination_group
  has_many :destination_tariffs
  has_many :tariffs, through: :destination_tariffs

  before_create :add_catch_all_prefixes

  private

  def add_catch_all_prefixes
    return unless catch_all?

    self.name = DEFAULT_CATCH_ALL_NAME
    self.prefixes = (0..9).map { prefixes.build(prefix: _1) }
  end
end
