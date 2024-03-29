module Services
  class MediaStreamEventsController < ServicesController
    def create
      validate_request_schema(
        with: MediaStreamEventRequestSchema, location: nil
      ) do |permitted_params|
        event = MediaStreamEvent.create!(permitted_params)
        ProcessMediaStreamEvent.call(event)
      end
    end

    def respond_with_resource(*)
      head(:created)
    end
  end
end
