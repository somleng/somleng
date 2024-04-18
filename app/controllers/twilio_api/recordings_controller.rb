module TwilioAPI
  class RecordingsController < TwilioAPIController
    include ActiveStorage::SetCurrent
    include ActionController::MimeResponds

    skip_before_action :doorkeeper_authorize!, only: :show
    skip_before_action :authorize_account!, only: :show

    def index
      recordings = parent_resource.recordings.page(params[:Page]).per(params[:PageSize])
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
      account = Account.find(params[:account_id])
      recording = account.recordings.find(params[:id])

      respond_to do |format|
        format.json { respond_with_resource(recording, serializer_options) }

        if recording.file.attached?
          format.wav { redirect_to(recording.file.url, allow_other_host: true) }
          format.mp3 { redirect_to(recording.mp3_file.url, allow_other_host: true) }
        elsif recording.raw_recording_url.present?
          raw_recording_object_key = URI(recording.raw_recording_url).path.delete_prefix("/")
          mp3_raw_recording_object_key = Pathname(raw_recording_object_key).sub_ext(".mp3").to_s

          format.wav { respond_with_raw_recording(raw_recording_object_key) }
          format.mp3 { respond_with_raw_recording(mp3_raw_recording_object_key) }
        else
          format.any { head :not_found }
        end
      end
    end

    private

    def respond_with_raw_recording(object_key)
      presigned_url = RawRecordingPresignedURL.new(object_key).presigned_url
      redirect_to(presigned_url, allow_other_host: true)
    end

    def parent_resource
      if params.key?(:phone_call_id)
        current_account.phone_calls.find(params[:phone_call_id])
      else
        current_account
      end
    end

    def serializer_options
      { serializer_class: RecordingSerializer }
    end
  end
end
