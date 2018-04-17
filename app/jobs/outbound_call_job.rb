# frozen_string_literal: true

class OutboundCallJob < ApplicationJob
  require 'drb'

  def perform(phone_call_id)
    phone_call = PhoneCall.find(phone_call_id)
    phone_call.external_id = drb_client.initiate_outbound_call!(
      phone_call.to_internal_outbound_call_json
    )

    phone_call.initiate_or_cancel!
  end

  private

  def drb_client
    raise('No DRB URL specified') unless drb_uri.present?
    @drb_client ||= DRbObject.new_with_uri(drb_uri)
  end

  def drb_uri
    Rails.application.secrets.fetch(:outbound_call_drb_uri)
  end
end
