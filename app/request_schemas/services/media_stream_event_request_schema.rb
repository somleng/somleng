module Services
  class MediaStreamEventRequestSchema < ServicesRequestSchema
    params do
      required(:media_stream_id).filled(:str?)
      required(:event).schema do
        required(:type).value(:string)
        optional(:details).maybe(:hash)
      end
    end

    rule(:media_stream_id) do |context:|
      context[:media_stream] = MediaStream.find_by(id: value)

      key.failure("does not exist") if context[:media_stream].blank?
    end

    def output
      params = super

      event = params.fetch(:event)
      {
        media_stream: context.fetch(:media_stream),
        phone_call: context.fetch(:media_stream).phone_call,
        type: event.fetch(:type),
        details: event.fetch(:details, {})
      }
    end
  end
end
