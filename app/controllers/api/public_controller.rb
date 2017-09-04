class Api::PublicController < Api::BaseController
  before_action :authorize_account!

  private

  def respond_with_account
    current_account
  end

  def account_from_params
    @account_from_params ||= Account.find(params[:account_id])
  end

  def authorize_account!
    deny_access! if current_account != account_from_params
  end

  def respond_with_resource
    respond_with(:api, respond_with_account, resource)
  end
end
