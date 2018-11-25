class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  delegate :serializer_class, to: :class

  def self.serializer_class
    "#{model_name}Serializer".constantize
  end
end
