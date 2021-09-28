module Services
  class DialStringsController < ServicesController
    def create
      account = Account.find(params.fetch(:account_sid))
      destination = Phony.normalize(params.fetch(:phone_number))
      destination_rules = DestinationRules.new(account: account, destination: destination)

      if destination_rules.valid?
        outbound_sip_trunk = destination_rules.sip_trunk
        dial_string = DialString.new(outbound_sip_trunk: outbound_sip_trunk, destination: destination)

        render json: { dial_string: dial_string.to_s }, status: :created
      else
        head :not_implemented
      end
    end
  end
end
