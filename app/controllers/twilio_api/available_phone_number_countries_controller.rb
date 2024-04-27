module TwilioAPI
  class AvailablePhoneNumberCountriesController < TwilioAPIController
    def index
      respond_with(scope, serializer_options)
    end

    def show
      country = scope.find_by(iso_country_code: params[:id])
      respond_with_resource(country, serializer_options)
    end

    private

    def scope
      current_account.carrier.phone_numbers.available.supported_countries
    end

    def serializer_options
      {
        serializer_class: AvailablePhoneNumberCountrySerializer,
        serializer_options: {
          paginate: false,
          account: current_account
        }
      }
    end
  end
end
