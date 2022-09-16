module Services
  class DialStringsController < ServicesController
    def create
      account = Account.find(params.fetch(:account_sid))
      destination = Phony.normalize(params.fetch(:phone_number))
      destination_rules = DestinationRules.new(account:, destination:)

      if destination_rules.valid?
        sip_trunk = destination_rules.sip_trunk
        dial_string = DialString.new(sip_trunk:, destination:)

        render(
          json: {
            dial_string: dial_string.to_s,
            nat_supported: sip_trunk.outbound_symmetric_latching_supported
          },
          status: :created
        )
      else
        head :not_implemented
      end
    end
  end
end
