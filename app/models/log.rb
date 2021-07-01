class Log < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :carrier
  belongs_to :account, optional: true
  belongs_to :phone_number, optional: true
end
