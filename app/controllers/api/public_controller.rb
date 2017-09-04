class Api::PublicController < Api::BaseController
  before_action :authorize_account!

  private

  def account_from_params
    @account_from_params ||= Account.find(params[:account_id])
  end

  def authorize_account!
    deny_access! if current_account != account_from_params
  end
end
