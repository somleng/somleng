class CallDataRecord < ApplicationRecord
  extend Enumerize

  enumerize :direction, in: %i[inbound outbound]

  attachment :file, content_type: ["application/json"]

  belongs_to :phone_call

  validates :file, presence: true

  validates :duration_sec,
            :bill_sec,
            numericality: { greater_than_or_equal_to: 0 }

  monetize :price_microunits,
           as: :price,
           numericality: {
             greater_than_or_equal_to: 0
           }

  def self.outbound
    where(direction: :outbound)
  end

  def self.inbound
    where(direction: :inbound)
  end

  def self.billable
    where(arel_table[:bill_sec].gt(0))
  end
end
