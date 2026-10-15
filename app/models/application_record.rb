class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.implicit_order_column = :sequence_number

  include SerializableResource
  include DecoratableResource
  include FilterableResource
  include OrderableResource
end
