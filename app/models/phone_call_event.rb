class PhoneCallEvent < ApplicationRecord
  self.inheritance_column = :_type_disabled
  extend Enumerize

  enumerize :type, in: %i[ringing answered completed]

  belongs_to :phone_call
end
