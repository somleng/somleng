class UpdatePhoneCallRequestSchema < ApplicationRequestSchema
  option :phone_call

  params do
    required(:Status).filled(:string, included_in?: ["completed"])
  end

  def output
    params = super

    {
      status: params.fetch(:Status)
    }
  end
end
