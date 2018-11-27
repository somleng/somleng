require "rails_helper"

describe ExecuteWorkflowJob do
  it "executes the workflow" do
    workflow = ApplicationWorkflow
    options = { "foo" => "bar" }
    allow(workflow).to receive(:call)

    described_class.perform_now(workflow.to_s, options)

    expect(workflow).to have_received(:call).with(options)
  end

  it "uses the default queue" do
    workflow = ApplicationWorkflow

    expect {
      described_class.perform_later(workflow.to_s)
    }.to have_enqueued_job.on_queue(
      Rails.configuration.app_settings.fetch("default_queue_url").split("/").last
    )
  end

  it "uses the workflow queue url if configured" do
    workflow = ApplicationWorkflow
    stub_app_settings(
      application_workflow_queue_url: "https://example.com/path/to/application_workflow_queue"
    )

    expect {
      described_class.perform_later(workflow.to_s)
    }.to have_enqueued_job.on_queue("application_workflow_queue")
  end
end
