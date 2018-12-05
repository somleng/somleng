class PhoneCallEvent < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :phone_call
  belongs_to :recording, optional: true
end
