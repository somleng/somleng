class Api::Internal::BaseController < Api::BaseController
  skip_before_action :api_authorize!
  http_basic_authenticate_with(name: "user", password: "password")
end
