class SIPTrunkResolver
  class Finder
    attr_reader :source_ip, :destination_number

    def initialize(**options)
      @source_ip = options.fetch(:source_ip)
      @destination_number = options[:destination_number]
    end

    def execute
      return find_sip_trunk(carrier_id: carriers.pluck(:carrier_id)) if carriers.one?

      find_sip_trunk(carrier_id: phone_number&.carrier_id)
    end

    private

    def carriers
      @carriers ||= SIPTrunkInboundSourceIPAddress.where(ip: source_ip).select(:carrier_id).distinct
    end

    def find_sip_trunk(carrier_id:)
      sip_trunks.where(carrier_id:).first
    end

    def sip_trunks
      SIPTrunk.joins(
        :sip_trunk_inbound_source_ip_addresses
      ).where(
        sip_trunk_inbound_source_ip_addresses: { ip: source_ip }
      )
    end

    def phone_number
      PhoneNumber.where(
        carrier: carriers.pluck(:carrier_id),
        number: normalized_destination_numbers
      ).first
    end

    def normalized_destination_numbers
      @normalized_destination_numbers ||= sip_trunks.find_each.map do |sip_trunk|
        sip_trunk.normalize_number(destination_number)
      end
    end
  end

  def find_sip_trunk_by(...)
    Finder.new(...).execute
  end
end
