class Api::Admin::PhoneCallsController < Api::Admin::BaseController
  private

  def association_chain
    resource_class
  end

  def setup_resource
    resource.incoming = true
  end

  def resource_class
    PhoneCall
  end

  def permitted_params
    params.permit("To", "From", "SomlengSid")
  end
end
