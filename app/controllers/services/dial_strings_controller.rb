module Services
  class DialStringsController < ServicesController
    def create
      routing_instructions = OutboundCallRouter.new(
        params.fetch(:phone_number)
      ).routing_instructions

      render json: routing_instructions, status: :created
    end
  end
end
