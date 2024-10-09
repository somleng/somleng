module TwilioAPI
  class AvailablePhoneNumberFilterRequestSchema < TwilioAPIRequestSchema
    def self.error_serializer_class
      TwilioAPI::BadRequestErrorSerializer
    end

    params do
      required(:type).value(:str?, included_in?: PhoneNumber.type.values.map(&:camelize))
      required(:country_code).value(:str?, included_in?: ISO3166::Country.all.map(&:alpha2))
      optional(:AreaCode).maybe(:str?)
      optional(:InRegion).maybe(:str?)
      optional(:InLocality).maybe(:str?)
      optional(:InLata).maybe(:str?)
      optional(:InRateCenter).maybe(:str?)
    end

    rule(:InLata, :InRateCenter) do
      key(:InRateCenter).failure("Must be used with InLata") if values[:InRateCenter].present? && values[:InLata].blank?
    end

    def output
      params = super

      result = {}
      result[:type] = params.fetch(:type).underscore
      result[:iso_country_code] = params.fetch(:country_code)
      result[:area_code] = params.fetch(:AreaCode) if params[:AreaCode].present?
      result[:iso_region_code] = params.fetch(:InRegion) if params[:InRegion].present?
      result[:locality] = params.fetch(:InLocality) if params[:InLocality].present?
      result[:lata] = params.fetch(:InLata) if params[:InLata].present?
      result[:rate_center] = params.fetch(:InRateCenter) if params[:InRateCenter].present?
      result
    end
  end
end
