module Services
  class DialStringsController < ServicesController
    def create
      routing_instructions = OutboundCallRouter.new(
        destination: params.fetch(:phone_number),
        account: Account.find(params.fetch(:account_sid))
      ).routing_instructions

      render json: routing_instructions, status: :created
    rescue OutboundCallRouter::UnsupportedGatewayError
      head :not_implemented
    end
  end
end
