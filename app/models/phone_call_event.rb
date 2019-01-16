class PhoneCallEvent < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :phone_call
  belongs_to :recording, optional: true

  delegate :url, to: :recording, prefix: true, allow_nil: true
end
