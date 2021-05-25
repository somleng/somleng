class Carrier < ApplicationRecord
  has_many :accounts
  has_many :outbound_sip_trunks
end
