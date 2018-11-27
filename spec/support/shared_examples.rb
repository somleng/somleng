shared_examples_for "aws_sqs_queue_url" do
  it "returns the default queue " do
    stub_app_settings(default_queue_url: "https://example.com/path/to/queue_name")
    expect(described_class.default_queue_name).to eq("queue_name")
  end
end
