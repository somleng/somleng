class Api::Admin::BaseController < Api::BaseController
  before_action :authorize_admin!

  private

  def api_authorize!
    super if check_admin_auth?
  end

  def request_basic_auth
    super if check_admin_auth?
  end

  def authorize_admin!
    deny_access! if check_admin_auth? && !current_account.permissions?(permission_name)
  end

  def check_admin_auth?
    Rails.env.production? || ENV["NO_ADMIN_AUTH"].to_i != 1
  end
end
