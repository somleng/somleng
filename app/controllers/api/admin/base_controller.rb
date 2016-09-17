class Api::Admin::BaseController < Api::BaseController
  before_action :authorize_admin!

  private

  def authorize_admin!
    deny_access! if !current_account.has_permission_to?(current_action, resource_class)
  end

  def current_action
    params[:action]
  end
end
