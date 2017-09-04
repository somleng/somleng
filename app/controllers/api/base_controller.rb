class Api::BaseController < ApplicationController
  self.responder = Api::BaseResponder
  protect_from_forgery :with => :null_session

  rescue_from ActiveRecord::RecordNotFound, :with => :not_found!
  respond_to :json
  before_action :request_basic_auth, :doorkeeper_authorize!

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

  def respond_with_create_resource
    respond_with(resource, respond_with_create_resource_options)
  end

  def respond_with_create_resource_options
    resource.persisted? ? {:location => resource_location} : {}
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

  def doorkeeper_unauthorized_render_options(error = nil)
    { :json => twilio_unauthorized_error }
  end

  def twilio_unauthorized_error(options = {})
    Twilio::ApiError::Unauthorized.new(options).to_hash
  end

  def twilio_not_found_error(options = {})
    Twilio::ApiError::NotFound.new({:request_url => request.original_fullpath}.merge(options))
  end

  def setup_resource
  end

  def save_resource
    resource.save
  end

  def resource
    @resource
  end

  def resources
    @resources
  end

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
    request_http_basic_authentication("Twilio API") if !request.authorization
  end

  def not_found!
    render(:json => twilio_not_found_error, :status => :not_found)
  end

  def deny_access!(options = {})
    render(:json => twilio_unauthorized_error(options), :status => :unauthorized)
  end

  def current_account
    @current_account ||= Account.find(doorkeeper_token && doorkeeper_token.resource_owner_id)
  end
end
