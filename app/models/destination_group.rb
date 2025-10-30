class DestinationGroup < ApplicationRecord
  belongs_to :carrier
  has_many :prefixes, class_name: "DestinationPrefix", dependent: :destroy, autosave: true, inverse_of: :destination_group
  has_many :destination_tariffs
  has_many :tariffs, through: :destination_tariffs

  def self.catch_all
    prefixes = (0..9).to_a

    where(
      id: where.not(
        id: DestinationPrefix.where.not(
          prefix: prefixes
        ).select(:destination_group_id)
      ).joins(:prefixes).group(:id).having(
        "COUNT(DISTINCT destination_prefixes.prefix) = ?", prefixes.size
      ).select(:id)
    )
  end
end
