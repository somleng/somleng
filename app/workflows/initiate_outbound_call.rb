class InitiateOutboundCall < ApplicationWorkflow
  require "drb"

  attr_accessor :phone_call

  def initialize(phone_call)
    self.phone_call = phone_call
  end

  def call
    call_params = API::Internal::PhoneCallSerializer.new(phone_call).to_json
    phone_call.external_id = initiate_remote_call!(call_params)
    phone_call.save!
    phone_call.initiate!
  end

  private

  def initiate_remote_call!(params)
    drb_client.initiate_outbound_call!(params)
  end

  def drb_client
    raise("No DRB URL specified") if drb_uri.blank?

    @drb_client ||= DRbObject.new_with_uri(drb_uri)
  end

  def drb_uri
    Rails.configuration.app_settings.fetch("outbound_call_drb_uri")
  end
end
