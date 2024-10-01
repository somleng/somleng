require "rails_helper"

RSpec.resource "Pagination", document: :twilio_api do
  explanation <<~HEREDOC
    When fetching multiple pages of API results, use the provided `next_page_uri` parameter to retrieve the next page of results.
  HEREDOC

  parameter(
    "PageSize",
    "How many resources to return in each list page. The default is 50, and the maximum is 100.",
  )

  get "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/Calls" do
    example "1. List Resources" do
      explanation <<~HEREDOC
        Some resources are lists of other resources.
        For example, the Calls list resource returns a list of calls. There are several important things to know about using and manipulating these lists.

        **Pagination Information**

        | Property          | Description                                                    |
        | ----------------- | -------------------------------------------------------------- |
        | uri               | The URI of the current page.                                   |
        | first_page_uri    | The URI for the first page of this list.                       |
        | next_page_uri     | The URI for the next page of this list.                        |
        | previous_page_uri | The URI for the previous page of this list.                    |
        | page              | The current page number. Zero-indexed, so the first page is 0. |
        | page_size         | How many items are in each page                                |

        **Paging Through API Resources**

        When fetching multiple pages of API results, use the provided `next_page_uri` parameter to retrieve the next page of results.

        You can control the size of pages with the `PageSize` parameter.
      HEREDOC

      account = create(:account)
      _older, newer, newest = 3.times.map { create(:phone_call, account:) }

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id, PageSize: 2)

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
      do_request(AccountSid: account.id, PageSize: 2, PageToken: "PA#{newest.id}")

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
      do_request(AccountSid: account.id, PageSize: 2, PageToken: "PB#{older.id}")

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
