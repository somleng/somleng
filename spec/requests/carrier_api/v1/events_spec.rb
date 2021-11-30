require "rails_helper"

resource "Events", document: :carrier_api do
  header("Content-Type", "application/vnd.api+json")

  get "https://api.somleng.org/carrier/v1/events" do
    example "List all events" do
      explanation <<~HEREDOC
        ### Types of events

        This is a list of all the types of events we currently send.
        We may add more at any time, so in developing and maintaining your code, you should not assume that only these types exist.

        You'll notice that these events follow a pattern: `resource.event`.
        Our goal is to design a consistent system that makes things easier to anticipate and code against.

        | Event |
        | ---- |
        #{Event.type.values.map { |type| '| `' + type + '` |' }.join("\n")}

      HEREDOC

      carrier = create(:carrier)
      events = [
        create(
          :event,
          type: "phone_call.completed",
          eventable: create(:phone_call, :completed),
          carrier: carrier
        )
      ]
      _other_event = create(:event)

      set_carrier_api_authorization_header(carrier)
      do_request

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("carrier_api/event")
      expect(json_response.fetch("data").pluck("id")).to match_array(events.pluck(:id))
    end
  end

  get "https://api.somleng.org/carrier/v1/events/:id" do
    example "Retrieve an Event" do
      event = create(:event)

      set_carrier_api_authorization_header(event.carrier)
      do_request(id: event.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/event")
    end
  end
end
