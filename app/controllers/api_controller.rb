class APIController < ApplicationController
  before_action :doorkeeper_authorize!
  before_action :authorize_account!

  private

  def authorize_account!
    return deny_access! unless current_account.enabled?
    return deny_access! unless current_account.id == params[:account_id]
  end

  def respond_with_resource(resource, options = {})
    respond_with(:api, resource.account, resource, **options)
  end

  def current_account
    @current_account ||= Account.find(doorkeeper_token.resource_owner_id)
  end
end
