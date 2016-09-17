class Api::PublicController < Api::BaseController
  before_action :authorize_account!
end
