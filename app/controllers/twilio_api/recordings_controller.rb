module TwilioAPI
  class RecordingsController < TwilioAPIController
    skip_before_action :doorkeeper_authorize!, only: :show
    skip_before_action :authorize_account!, only: :show

    def index
      phone_call = phone_calls_scope.find(params[:phone_call_id])
      recordings = phone_call.recordings.page(params[:Page]).per(params[:PageSize])
      respond_with(
        recordings,
        serializer_options.merge(
          serializer_options: {
            url: request.fullpath
          }
        )
      )
    end

    def show
      recording = Recording.find(params[:id])
      respond_with_resource(recording, serializer_options)
    end

    private

    def phone_calls_scope
      current_account.phone_calls
    end

    def serializer_options
      { serializer_class: RecordingSerializer }
    end
  end
end
