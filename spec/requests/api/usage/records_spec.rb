require "rails_helper"

describe "Usage Records API" do
  describe "GET /api/2010-04-01/Accounts/{AccountSid}/Usage/Records" do
    it "fetches the usage records" do
      account = create(:account)
      params = {}

      get(
        api_twilio_account_usage_records_path(account.id, params),
        headers: build_api_authorization_headers(account)
      )

      expect(response.code).to eq("200")
      expect(response.body).to match_api_response_schema(:usage_record_collection)
      expect(JSON.parse(response.body).fetch("usage_records").size).to eq(3)
    end

    it "handles invalid requests" do
      account = create(:account)
      params = { Category: "foo" }

      get(
        api_twilio_account_usage_records_path(account, params),
        headers: build_api_authorization_headers(account)
      )

      expect(response.code).to eq("422")
      expect(response.body).to match_api_response_schema(:api_error)
    end

    it "filters by start and end date" do
      account = create(:account)
      create_phone_call_with_cdr(:billable, account: account, start_time: Date.new(2018, 1, 1))
      create_phone_call_with_cdr(:billable, account: account, start_time: Date.new(2018, 1, 2))
      create_phone_call_with_cdr(:billable, account: account, start_time: Date.new(2018, 1, 3))

      params = {
        StartDate: "2018-01-02",
        EndDate: "2018-01-02",
        Category: "calls"
      }

      get(
        api_twilio_account_usage_records_path(account, params),
        headers: build_api_authorization_headers(account)
      )

      expect(response.code).to eq("200")
      expect(response.body).to match_api_response_schema(:usage_record_collection)
      usage_record = JSON.parse(response.body).fetch("usage_records").first
      expect(usage_record.fetch("start_date")).to eq("2018-01-02")
      expect(usage_record.fetch("end_date")).to eq("2018-01-02")
      expect(usage_record.fetch("category")).to eq("calls")
      expect(usage_record.fetch("count")).to eq("1")
    end
  end
end
