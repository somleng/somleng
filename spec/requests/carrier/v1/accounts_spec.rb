require "rails_helper"

RSpec.resource "Carrier / Accounts API"  do
  header("Content-Type", "application/vnd.api+json")

  let(:raw_post) { params.to_json }

  post "/carrier/v1/accounts" do
    example "Creates an account" do
      carrier = create(:carrier)
      outbound_sip_trunk = create(:outbound_sip_trunk, carrier: carrier)

      set_carrier_api_authorization_header(carrier)
      do_request(
        data: {
          type: :carrier,
          attributes: {
            name: "Early Warning System",
            metadata: {
              foo: :bar
            }
          },
          relationships: {
            outbound_sip_trunk: {
              data: {
                type: :outbound_sip_trunk,
                id: outbound_sip_trunk.id
              }
            }
          }
        }
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_api_resource_schema(:account)
      expect(json_response.dig("data", "attributes", "metadata")).to eq("foo" => "bar")
    end
  end
end
