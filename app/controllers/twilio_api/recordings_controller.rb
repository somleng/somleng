module TwilioAPI
  class RecordingsController < TwilioAPIController
    skip_before_action :doorkeeper_authorize!
    skip_before_action :authorize_account!

    def show
      recording = Recording.find(params[:id])
      respond_with_resource(recording, serializer_options)
    end

    private

    def serializer_options
      { serializer_class: RecordingSerializer }
    end
  end
end
