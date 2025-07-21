require "csv"

class PublishInteractionData < ApplicationWorkflow
  attr_reader :api_key, :chart_id

  def initialize(**options)
    super()
    @api_key = options.fetch(:api_key) { AppSettings[:datawrapper_api_key] }
    @chart_id = options.fetch(:chart_id) { AppSettings[:datawrapper_chart_id] }
  end

  def call
    return if chart_id.blank?

    response = make_request(:get, "/data")
    csv = CSV.parse(response.body, headers: true)
    return if csv.any? { |r| Date.parse(r["Date"]) == Date.current }

    csv << build_data_point
    make_request(:put, "/data", csv.to_s, headers: { "Content-Type" => "text/csv" })
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

  def make_request(http_method, path, data = nil, headers: {})
    response = client.run_request(http_method, "/v3/charts/#{chart_id}#{path}", data, headers)
    raise "HTTP Error #{response.status}: #{response.body}" unless response.success?

    response
  end

  def client
    @client ||= Faraday.new(url: "https://api.datawrapper.de") do |conn|
      conn.adapter Faraday.default_adapter

      conn.request(:authorization, "Bearer", api_key)
    end
  end
end
