class Api::Admin::BaseController < Api::BaseController
  before_action :authorize_admin!

  private

  def authorize_admin!
    deny_access! if !current_account.permissions?(permission_name)
  end
end
