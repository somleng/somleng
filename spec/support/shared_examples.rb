shared_examples_for "aws_sqs_queue_url" do
  it "returns the queue name based on the job" do
    stub_app_settings("#{described_class.to_s.underscore}_queue_url" => "https://example.com/path/to/custom_queue_name")
    expect(described_class.aws_sqs_queue_url).to eq("https://example.com/path/to/custom_queue_name")
  end

  it "returns the default queue by default" do
    stub_app_settings(default_queue_url: "https://example.com/path/to/queue_name")
    expect(described_class.aws_sqs_queue_url).to eq("https://example.com/path/to/queue_name")
  end
end
