class DashboardResponder < ApplicationResponder
  include Responders::FlashResponder

  self.error_status = :unprocessable_entity
  self.redirect_status = :see_other
end
