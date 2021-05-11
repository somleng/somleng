class APIController < ApplicationController
  before_action :doorkeeper_authorize!
  before_action :authorize_account!

  private

  def authorize_account!
    return deny_access! unless current_account.enabled?
    return deny_access! unless current_account.id == params[:account_id]
  end

  def respond_with_resource(resource, options = {})
    respond_with(resource.account, resource, **options)
  end

  def current_account
    @current_account ||= Account.find(doorkeeper_token.resource_owner_id)
  end

  def deny_access!
    render(unauthorized_render_options)
  end

  def doorkeeper_unauthorized_render_options(**)
    unauthorized_render_options
  end

  def doorkeeper_forbidden_render_options(**)
    unauthorized_render_options
  end

  def unauthorized_render_options
    {
      json: {
        "code": 20003,
        "detail": "",
        "message": "Authenticate",
        "more_info": "https://www.twilio.com/docs/errors/20003",
        "status": 401
      },
      status: :unauthorized
    }
  end
end
