class ExecuteWorkflowJob < ApplicationJob
  queue_as do
    workflow_name = arguments.first

    workflow_queue_url = Rails.configuration.app_settings["#{workflow_name.underscore}_queue_url"]
    workflow_queue_url.present? ? self.class.parse_queue_name(workflow_queue_url) : self.class.default_queue_name
  end

  def perform(workflow_name, *args)
    workflow_name.constantize.call(*args)
  end
end
