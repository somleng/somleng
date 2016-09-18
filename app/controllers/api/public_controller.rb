class Api::PublicController < Api::BaseController
  before_action :authorize_account!

  private

  def authorize_account!
    deny_access! if current_account != Account.find_by_id(params[:account_id])
  end

  def respond_with_resource
    respond_with(:api, current_account, resource)
  end
end
