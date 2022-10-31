class SMSGatewayChannelFilter < ResourceFilter
  class SMSGatewayFilter < ApplicationFilter
    filter_params do
      optional(:sms_gateway_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(sms_gateway_id: filter_params.fetch(:sms_gateway_id))
    end
  end

  class ChannelGroupFilter < ApplicationFilter
    filter_params do
      optional(:channel_group_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(sms_gateway_channel_group_id: filter_params.fetch(:channel_group_id))
    end
  end

  class PhoneNumberFilter < ApplicationFilter
    filter_params do
      optional(:phone_number_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(phone_number_id: filter_params.fetch(:phone_number_id))
    end
  end

  filter_with SMSGatewayFilter, ChannelGroupFilter, PhoneNumberFilter, NameFilter, DateFilter
end
