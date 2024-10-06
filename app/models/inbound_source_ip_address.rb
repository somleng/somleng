class InboundSourceIPAddress < ApplicationRecord
  has_many :sip_trunk_inbound_source_ip_addresses
  has_many :sip_trunks, through: :sip_trunk_inbound_source_ip_addresses
  has_many :carriers, through: :sip_trunks
end
