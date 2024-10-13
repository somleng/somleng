class SIPTrunkInboundSourceIPAddress < ApplicationRecord
  belongs_to :sip_trunk
  belongs_to :carrier
  belongs_to :inbound_source_ip_address

  before_validation :set_carrier

  def ip=(value)
    super
    self.inbound_source_ip_address = InboundSourceIPAddress.find_or_initialize_by(ip:)
  end

  private

  def set_carrier
    self.carrier ||= sip_trunk.carrier
  end
end
