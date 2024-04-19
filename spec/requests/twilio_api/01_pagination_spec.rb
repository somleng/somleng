require "rails_helper"

RSpec.resource "Pagination", document: :twilio_api do
  explanation <<~HEREDOC
    When fetching multiple pages of API results, use the provided `next_page_uri` parameter to retrieve the next page of results.
  HEREDOC

  parameter(
    :PageSize, "How many resources to return in each list page. The default is 50, and the maximum is 100.",
    :limit, "Upper limit for the number of records to return. Guarantees to never return more than limit.  Default is no limit"
  )

  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Calls" do
    example "List resources with PageSize" do
      account = create(:account)
      _older, newer, newest = 3.times.map { create(:phone_call, account:) }

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id, PageSize: 2)

      expect(response_status).to eq(200)
      expect(json_response.fetch("calls").size).to eq(2)
      expect(json_response.dig("calls", 0, "sid")).to eq(newest.id)
      expect(json_response.dig("calls", 1, "sid")).to eq(newer.id)

      expect(json_response).to include(
        "page" => 0,
        "page_size" => 2,
        "uri" => api_twilio_account_phone_calls_path(account, PageSize: 2),
        "first_page_uri" => api_twilio_account_phone_calls_path(
          account, Page: 0, PageSize: 2
        ),
        "next_page_uri" => api_twilio_account_phone_calls_path(
          account, Page: 1, PageSize: 2, PageToken: "PA#{newer.id}"
        ),
        "previous_page_uri" => api_twilio_account_phone_calls_path(
          account, Page: 0, PageSize: 2, PageToken: "PB#{newest.id}"
        )
      )
    end

    example "List next result", document: false do
      account = create(:account)
      older, newer, newest = 3.times.map { create(:phone_call, account:) }

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id, PageSize: 2, PageToken: "PA#{newest.id}")

      expect(response_status).to eq(200)
      expect(json_response.fetch("calls").size).to eq(2)
      expect(json_response.dig("calls", 0, "sid")).to eq(newer.id)
      expect(json_response.dig("calls", 1, "sid")).to eq(older.id)

      expect(json_response).to include(
        "page" => 0,
        "page_size" => 2,
        "uri" => api_twilio_account_phone_calls_path(account, PageSize: 2,
                                                              PageToken: "PA#{newest.id}"),
        "first_page_uri" => api_twilio_account_phone_calls_path(account, Page: 0, PageSize: 2),
        "next_page_uri" => nil,
        "previous_page_uri" => api_twilio_account_phone_calls_path(account, Page: 0, PageSize: 2,
                                                                            PageToken: "PB#{newer.id}")
      )
    end

    example "List previous result", document: false do
      account = create(:account)
      _oldest, older, newer, newest = 4.times.map { create(:phone_call, account:) }

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id, PageSize: 2, PageToken: "PB#{older.id}")

      expect(response_status).to eq(200)
      expect(json_response.fetch("calls").size).to eq(2)
      expect(json_response.dig("calls", 0, "sid")).to eq(newest.id)
      expect(json_response.dig("calls", 1, "sid")).to eq(newer.id)

      expect(json_response).to include(
        "page" => 0,
        "page_size" => 2,
        "uri" => api_twilio_account_phone_calls_path(account, PageSize: 2,
                                                              PageToken: "PB#{older.id}"),
        "first_page_uri" => api_twilio_account_phone_calls_path(account, Page: 0, PageSize: 2),
        "next_page_uri" => api_twilio_account_phone_calls_path(account, Page: 1, PageSize: 2,
                                                                        PageToken: "PA#{newer.id}"),
        "previous_page_uri" => nil
      )
    end
  end
end
