class TwilioAPIController < APIController
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  self.responder = TwilioAPI::Responder

  before_action :doorkeeper_authorize!
  before_action :authorize_account!

  private

  def authorize_account!
    return deny_access! unless authenticate_with_http_basic do |given_name|
      ActiveSupport::SecurityUtils.secure_compare(given_name, current_account.id)
    end
    return deny_access!(build_error(:account_suspended)) unless current_account.enabled?
    return deny_access! if verify_account_param? && current_account.id != params[:account_id]
    return if CarrierStanding.new(current_account.carrier).good_standing?

    deny_access!(build_error(:carrier_standing))
  end

  def verify_account_param?
    true
  end

  def respond_with_resource(resource, options = {})
    respond_with(:api, :twilio, resource.account, resource, **options)
  end

  def current_account
    @current_account ||= Account.find(doorkeeper_token.resource_owner_id)
  end

  def deny_access!(...)
    render(unauthorized_render_options(...))
  end

  def doorkeeper_unauthorized_render_options(**)
    unauthorized_render_options
  end

  def doorkeeper_forbidden_render_options(**)
    unauthorized_render_options
  end

  def unauthorized_render_options(options = {})
    code = options.fetch(:code, "20003")
    message = options.fetch(:message, "Authenticate")
    {
      json: {
        code:,
        message:,
        detail: "",
        more_info: "https://www.twilio.com/docs/errors/#{code}",
        status: 401
      },
      status: :unauthorized
    }
  end

  def build_error(code)
    error = ApplicationError::Errors.fetch(code)
    { message: error.message, code: error.code }
  end
end
