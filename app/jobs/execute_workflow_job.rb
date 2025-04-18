class ExecuteWorkflowJob < ApplicationJob
  def perform(workflow, *, **)
    workflow.constantize.call(*, **)
  end
end
