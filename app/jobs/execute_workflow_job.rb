class ExecuteWorkflowJob < ApplicationJob
  def perform(workflow, *args)
    workflow.constantize.call(*args)
  end
end
