class Api::RecordingsController < Api::BaseController
  respond_to :json
  respond_to :wav, only: :show

  skip_before_action :request_basic_auth,
                     :doorkeeper_authorize!,
                     :authorize_account!,
                     only: :show

  private

  def association_chain
    index_action? ? phone_call.recordings : account_from_params.recordings
  end

  def phone_call
    current_account.phone_calls.find(params[:phone_call_id])
  end

  def index_action?
    action_name == "index"
  end
end
