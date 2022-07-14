class WebhookRequestLogPolicy < ApplicationPolicy
  def read?
    managing_carrier?
  end
end
