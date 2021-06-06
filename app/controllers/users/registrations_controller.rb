class Users::RegistrationsController < Devise::RegistrationsController
  include UserAuthorization
  layout "dashboard"
end
