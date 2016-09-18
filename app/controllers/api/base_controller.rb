class Api::BaseController < ApplicationController
  protect_from_forgery :with => :null_session

  respond_to :json
  before_action :request_basic_auth, :doorkeeper_authorize!

  def create
    build_resource
    setup_resource
    save_resource
    respond_with_resource
  end

  def show
    find_resource
    respond_with_resource
  end

  private

  def setup_resource
  end

  def save_resource
    resource.save
  end

  def resource
    @resource
  end

  def build_resource
    @resource = association_chain.new(permitted_params)
  end

  def find_resource
    @resource = association_chain.find(params[:id])
  end

  def request_basic_auth
    request_http_basic_authentication("Twilio API") if !request.authorization
  end

  def deny_access!
    head(:unauthorized)
  end

  def current_account
    @current_account ||= Account.find(doorkeeper_token && doorkeeper_token.resource_owner_id)
  end
end
