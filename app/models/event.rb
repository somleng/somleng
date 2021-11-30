class Event < ApplicationRecord
  self.inheritance_column = :_type_disabled

  extend Enumerize

  TYPES = %i[
    phone_call.completed
  ].freeze

  belongs_to :eventable, polymorphic: true
  belongs_to :carrier

  has_many :webhook_request_logs

  enumerize :type, in: TYPES
end
