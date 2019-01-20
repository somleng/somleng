require "rails_helper"

describe ProcessRecording do
  it "processes the recording" do
    aws_client = fake_aws_client(
      get_object: {
        body: file_fixture("sample_audio.wav").read,
        content_type: "audio/x-wav"
      }
    )
    stub_aws_client(aws_client)

    recording = create(:recording, :waiting_for_file)

    described_class.call(recording, "recording.somleng.org", "/recordings/sample_audio.wav")

    expect(recording.reload).to have_attributes(
      file_content_type: "audio/x-wav",
      file_filename: "sample_audio.wav",
      status: "completed"
    )
  end

  def stub_aws_client(aws_client)
    allow(Aws::S3::Client).to receive(:new).and_return(aws_client)
  end

  def fake_aws_client(stub_responses = {})
    Aws::S3::Client.new(stub_responses: stub_responses)
  end
end
