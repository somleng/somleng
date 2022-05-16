module TwilioAPI
  class RecordingsController < TwilioAPIController
    include ActiveStorage::SetCurrent
    include ActionController::MimeResponds

    skip_before_action :doorkeeper_authorize!, only: :show
    skip_before_action :authorize_account!, only: :show
    skip_before_action :verify_custom_domain!, only: :show

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
      if app_request.custom_domain_request?
        app_request.find_custom_domain!(:api)
      end

      account = Account.find(params[:account_id])
      recording = account.recordings.find(params[:id])

      respond_to do |format|
        format.json { respond_with_resource(recording, serializer_options) }

        format.wav do
          if recording.file.attached?
            redirect_to(recording.file.url, allow_other_host: true)
          else
            head :not_found
          end
        end
      end
    end

    private

    def parent_resource
      if params.key?(:phone_call_id)
        current_account.phone_calls.find(params[:phone_call_id])
      else
        current_account
      end
    end

    def phone_calls_scope
    end

    def serializer_options
      { serializer_class: RecordingSerializer }
    end
  end
end
