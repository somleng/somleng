class Api::BaseController < ApplicationController
  self.responder = ApiResponder

  respond_to :json

  # protect_from_forgery with: :null_session

  rescue_from ActiveRecord::RecordNotFound, with: :not_found!

  before_action :request_basic_auth
  before_action :doorkeeper_authorize!
  before_action :authorize_account!

  def create
    build_resource
    setup_resource
    save_resource
    respond_with_create_resource
  end

  def show
    find_resource
    respond_with_show_resource
  end

  def index
    find_resources
    respond_with_resources
  end

  private

  def account_from_params
    @account_from_params ||= Account.find(params[:account_id])
  end

  def authorize_account!
    return deny_access! unless current_account.enabled?
    return deny_access! unless current_account == account_from_params
  end

  def respond_with_create_resource
    respond_with(resource, respond_with_create_resource_options)
  end

  def respond_with_create_resource_options
    resource.persisted? ? { location: resource_location } : {}
  end

  def respond_with_show_resource
    respond_with_resource
  end

  def respond_with_resource
    respond_with(resource)
  end

  def respond_with_resources
    respond_with(resources)
  end

  def doorkeeper_unauthorized_render_options(_error = nil)
    { json: twilio_unauthorized_error }
  end

  def twilio_unauthorized_error(options = {})
    Twilio::ApiError::Unauthorized.new(options).to_hash
  end

  def twilio_not_found_error(options = {})
    Twilio::ApiError::NotFound.new({ request_url: request.original_fullpath }.merge(options))
  end

  def setup_resource; end

  def save_resource
    resource.save
  end

  attr_reader :resource, :resources

  def build_resource
    @resource = association_chain.new(permitted_params)
  end

  def find_resource
    @resource = association_chain.find(params[:id])
  end

  def find_resources
    @resources = association_chain
  end

  def request_basic_auth
    request_http_basic_authentication("Twilio API") unless request.authorization
  end

  def not_found!
    render(json: twilio_not_found_error, status: :not_found)
  end

  def deny_access!(options = {})
    render(json: twilio_unauthorized_error(options), status: :unauthorized)
  end

  def current_account
    @current_account ||= Account.find(doorkeeper_token&.resource_owner_id)
  end
end
