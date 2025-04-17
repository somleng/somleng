require "csv"

class PublishInteractionData < ApplicationWorkflow
  attr_reader :api_key, :chart_id

  def initialize(api_key: AppSettings.fetch(:datawrapper_api_key),
                 chart_id: AppSettings.fetch(:datawrapper_chart_id))
    @api_key = api_key
    @chart_id = chart_id
  end

  def call
    return if chart_id.blank?

    response = make_request(:get, "/data")
    csv = CSV.parse(response.body, headers: true)
    return if csv.any? { |r| Date.parse(r["Date"]) == Date.current }

    csv << build_data_point
    make_request(:put, "/data", csv.to_s)
    make_request(:post, "/publish")
  end

  private

  def build_data_point
    [
      Date.current.to_s,
      Interaction.select(:beneficiary_fingerprint).distinct.count,
      Interaction.count
    ]
  end

  def make_request(http_method, path, data = nil)
    response = client.run_request(http_method, "/v3/charts/#{chart_id}#{path}", data, {})
    raise "HTTP Error #{response.status}: #{response.body}" unless response.success?

    response
  end

  def client
    @client ||= Faraday.new(url: "https://api.datawrapper.de") do |conn|
      conn.headers["Content-Type"] = "text/csv"

      conn.adapter Faraday.default_adapter

      conn.request(:authorization, "Bearer", api_key)
    end
  end
end
