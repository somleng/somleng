class CarrierSIPTrunkPermission < ApplicationRecord
  belongs_to :carrier
  belongs_to :sip_trunk_permission
end
