class DashboardResponder < ApplicationResponder
  include Responders::FlashResponder

  self.redirect_status = :see_other
end
