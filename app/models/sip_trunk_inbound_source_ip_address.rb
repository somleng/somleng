class SIPTrunkInboundSourceIPAddress < ApplicationRecord
  belongs_to :sip_trunk
  belongs_to :inbound_source_ip_address
end
