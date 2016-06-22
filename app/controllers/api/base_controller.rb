class Api::BaseController < ApplicationController
  respond_to :json
  before_action :doorkeeper_authorize!, :authorize_account!

  private

  def deny_access!
    head(:unauthorized)
  end

  def authorize_account!
    deny_access! if current_account != Account.find_by_id(params[:account_id])
  end

  def current_account
    @current_account ||= Account.find(doorkeeper_token && doorkeeper_token.resource_owner_id)
  end
end
