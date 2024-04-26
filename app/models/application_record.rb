class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.implicit_order_column = :sequence_number

  include SerializableResource
  include DecoratableResource

  scope :latest_first, -> { order(sequence_number: :desc) }

  def self.filter_class
    "#{model_name}Filter".constantize
  end
end
