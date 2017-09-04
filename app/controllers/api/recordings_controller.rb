class Api::RecordingsController < Api::PublicController
  respond_to :wav, :json
  skip_before_action :request_basic_auth, :doorkeeper_authorize!, :authorize_account!

  private

  def association_chain
    account_from_params.recordings
  end

  def respond_with_account
    account_from_params
  end
end
