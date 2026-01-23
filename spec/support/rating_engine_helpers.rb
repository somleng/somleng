module RatingEngineHelpers
  def stub_rating_engine_request(options = {})
    options.reverse_merge!(
      response: { result: "OK", error: nil }
    )

    stub_request(:post, "#{AppSettings.fetch(:rating_engine_host)}/jsonrpc").to_return ->(request) {
      {
        status: 200,
        body: JSON.parse(request.body).slice("id").merge(options.fetch(:response)).to_json,
        headers: { "Content-Type" => "application/json" }
      }
    }
  end
end

RSpec.configure do |config|
  config.include RatingEngineHelpers
end
