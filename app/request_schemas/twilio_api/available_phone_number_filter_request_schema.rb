module TwilioAPI
  class AvailablePhoneNumberFilterRequestSchema < TwilioAPIRequestSchema
    def self.error_serializer_class
      TwilioAPI::BadRequestErrorSerializer
    end

    params do
      required(:type).value(:str?, included_in?: PhoneNumber.type.values.map(&:camelize))
      required(:country_code).value(:str?, included_in?: ISO3166::Country.all.map(&:alpha2))
      optional(:AreaCode).maybe(:str?)
    end

    def output
      params = super

      result = {}
      result[:type] = params.fetch(:type).underscore,
      result[:iso_country_code] = params.fetch(:country_code)
      result[:area_code] = params.fetch(:AreaCode) if params[:AreaCode].present?
      result
    end
  end
end
