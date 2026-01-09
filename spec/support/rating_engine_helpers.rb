module RatingEngineHelpers
  def stub_rating_engine_request
    stub_request(:post, "#{AppSettings.fetch(:rating_engine_host)}/jsonrpc").to_return ->(request) {
      {
        status: 200,
        body: JSON.parse(request.body).slice("id").merge(result: "OK", error: nil).to_json,
        headers: { "Content-Type" => "application/json" }
      }
    }
  end
end
