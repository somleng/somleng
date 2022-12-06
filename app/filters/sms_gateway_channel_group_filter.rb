class SMSGatewayChannelGroupFilter < ResourceFilter
  class SMSGatewayFilter < ApplicationFilter
    filter_params do
      optional(:sms_gateway_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(sms_gateway_id: filter_params.fetch(:sms_gateway_id))
    end
  end

  filter_with SMSGatewayFilter, :name_filter, :date_filter
end
