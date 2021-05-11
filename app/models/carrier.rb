class Carrier < ApplicationRecord
  has_many :outbound_sip_trunks
end
