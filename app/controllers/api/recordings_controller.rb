class Api::RecordingsController < Api::PublicController
  respond_to :wav, :json

  private

  def association_chain
    current_account.recordings
  end
end
