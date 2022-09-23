module Services
  class RoutingParametersController < ServicesController
    def create
      account = Account.find(params.fetch(:account_sid))
      destination = params.fetch(:phone_number).gsub(/\D/, "")
      destination_rules = DestinationRules.new(account:, destination:)

      if destination_rules.valid?
        sip_trunk = destination_rules.sip_trunk
        routing_parameters = RoutingParameters.new(sip_trunk:, destination:).to_h

        render(
          json: routing_parameters,
          status: :created
        )
      else
        head :not_implemented
      end
    end
  end
end
