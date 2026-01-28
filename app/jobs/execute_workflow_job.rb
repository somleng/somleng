class ExecuteWorkflowJob < ApplicationJob
  def perform(workflow, ...)
    workflow.safe_constantize.call(...)
  end
end
