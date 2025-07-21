require "rails_helper"

RSpec.describe PublishInteractionData do
  it "publishes interaction data" do
    create_phone_call_interaction(phone_call_params: { to: "855715900760" })
    create_phone_call_interaction(phone_call_params: { to: "855715900760" })
    create_phone_call_interaction(phone_call_params: { to: "61438576076" })
    create(:interaction, interactable: create(:message, :robot))

    csv_data = CSV.generate(headers: true) do |csv|
      csv << %w[Date Beneficiaries Interactions]
      csv << %w[2023-01-01 1 2]
    end

    stub_request(:get, "https://api.datawrapper.de/v3/charts/chart-id/data").to_return(
      status: 200,
      body: csv_data.to_s
    )
    stub_request(:put, "https://api.datawrapper.de/v3/charts/chart-id/data").to_return(
      status: 204
    )
    stub_request(:post, "https://api.datawrapper.de/v3/charts/chart-id/publish").to_return(
      status: 200
    )

    PublishInteractionData.call(api_key: "api-key", chart_id: "chart-id")

    expect(WebMock).to(
      have_requested(
        :put,
        "https://api.datawrapper.de/v3/charts/chart-id/data"
      ).with do |request|
        csv = CSV.parse(request.body, headers: true)
        expect(csv.to_a).to eq([
          %w[Date Beneficiaries Interactions],
          %w[2023-01-01 1 2],
          [ Date.current.to_s, "2", "4" ]
        ])
        expect(request.headers["Content-Type"]).to eq("text/csv")
      end
    )

    expect(WebMock).to(
      have_requested(:post, "https://api.datawrapper.de/v3/charts/chart-id/publish").with do |request|
        expect(request.headers["Authorization"]).to eq("Bearer api-key")
        expect(request.headers).not_to include("Content-Type")
      end
    )
  end

  it "does not publish if the date already exists" do
    csv_data = CSV.generate(headers: true) do |csv|
      csv << %w[Date Beneficiaries Interactions]
      csv << %w[2023-01-01 1 2]
      csv << [ Date.current.to_s, 1, 1 ]
    end

    stub_request(:get, "https://api.datawrapper.de/v3/charts/chart-id/data").to_return(
      status: 200,
      body: csv_data.to_s
    )
    stub_request(:put, "https://api.datawrapper.de/v3/charts/chart-id/data")
    stub_request(:post, "https://api.datawrapper.de/v3/charts/chart-id/publish")

    PublishInteractionData.call(api_key: "api-key", chart_id: "chart-id")

    expect(WebMock).not_to have_requested(:put, "https://api.datawrapper.de/v3/charts/chart-id/data")
  end

  def create_phone_call_interaction(phone_call_params: {}, **params)
    phone_call = create(:phone_call, :outbound, :completed, phone_call_params)
    create(:interaction, interactable: phone_call, **params)
  end
end
