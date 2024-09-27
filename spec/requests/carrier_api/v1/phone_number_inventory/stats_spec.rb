require "rails_helper"

resource "Phone Number Inventory:Stats", document: :carrier_api do
  header("Content-Type", "application/vnd.api+json")

  get "https://api.somleng.org/carrier/v1/phone_number_inventory/stats" do
    with_options scope: :filter do
      parameter(
        :available, "Whether to return only available phone numbers. Must be `true`",
        required: true
      )
      parameter(
        :type, "The phone number type. Must be `local`",
        required: true
      )
    end

    parameter(
      :group_by,
      "An array of fields to group by. Must be `['country', 'locality', 'region']`",
      reguired: true
    )

    with_options scope: [ :having, :count ] do
      parameter(
        :operator, "One of `eq`, `neq`, `gt`, `gteq`, `lt`, `lteq`"
      )
      parameter(
        :value, "The value of the count. Must be an integer greater than or equal to 0"
      )
    end

    example "1. Get number of available phone numbers per locality having a count less than 2" do
      carrier = create(:carrier)
      create(:phone_number, carrier:, type: :local, number: "12513095500", iso_country_code: "US", iso_region_code: "AK", locality: "Little Rock")
      create(:phone_number, carrier:, type: :local, number: "12513095501", iso_country_code: "US", iso_region_code: "AK", locality: "Little Rock")
      create(:phone_number, carrier:, type: :local, number: "12513095502", iso_country_code: "US", iso_region_code: "AL", locality: "Tuscaloosa")
      create(:phone_number, carrier:, type: :local, number: "12513095503", iso_country_code: "US", iso_region_code: "AL", locality: "Birmingham")
      create(:phone_number, carrier:, type: :local, number: "12513095504", iso_country_code: "US", iso_region_code: "AL", locality: "Huntsville")

      set_carrier_api_authorization_header(carrier)
      do_request(
        filter: {
          available: true,
          type: :local
        },
        group_by: [ "country", "region", "locality" ],
        having: {
          count: { lt: 2 }
        },
        page: {
          after: AggregateData::IDGenerator.new.generate_id([ "US", "Birmingham", "AL" ])
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("carrier_api/aggregate_data")
      statistics = json_response.fetch("data").map { |data| data.dig("attributes", "statistic") }
      expect(statistics).to eq(
        [
          {
            "country" => "US",
            "region" => "AL",
            "locality" => "Huntsville",
            "value" => 1
          },
          {
            "country" => "US",
            "region" => "AL",
            "locality" => "Tuscaloosa",
            "value" => 1
          }
        ]
      )
    end

    example "Handles invalid requests", document: false do
      carrier = create(:carrier)

      set_carrier_api_authorization_header(carrier)
      do_request

      expect(response_status).to eq(400)
    end
  end
end
