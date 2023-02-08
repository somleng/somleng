class ExecuteWorkflowJob < ApplicationJob
  def perform(workflow, *args, **kwargs)
    workflow.constantize.call(*args, **kwargs)
  end
end
