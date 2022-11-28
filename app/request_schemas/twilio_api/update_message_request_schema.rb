module TwilioAPI
  class UpdateMessageRequestSchema < TwilioAPIRequestSchema
    option :message

    params do
      required(:Body).filled(:string)
    end

    def output
      params = super

      {
        body: params.fetch(:Body)
      }
    end
  end
end
