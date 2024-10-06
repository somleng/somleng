class SIPTrunkPermission < ApplicationRecord
  has_many :carrier_sip_trunk_permissions
  has_many :carriers, through: :carrier_sip_trunk_permissions
end
