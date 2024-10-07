class SIPTrunkInboundSourceIPAddress < ApplicationRecord
  belongs_to :sip_trunk
  belongs_to :inbound_source_ip_address

  def ip=(value)
    super
    self.inbound_source_ip_address = InboundSourceIPAddress.find_or_initialize_by(ip:)
  end
end
