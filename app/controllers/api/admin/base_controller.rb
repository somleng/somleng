class Api::Admin::BaseController < Api::BaseController
  before_action :authorize_admin!

  private

  def authorize_admin!
    deny_access! if check_admin_auth? && !current_account.permissions?(permission_name)
  end

  def check_admin_auth?
    ENV["NO_ADMIN_AUTH"].to_i != 1
  end
end
