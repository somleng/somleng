class ExecuteWorkflowJob < ApplicationJob
  def perform(workflow, *, **options)
    with_logger = options.delete(:with_logger)
    kwargs = with_logger ? { logger:, **options } : { **options }
    workflow.constantize.call(*, **kwargs)
  end
end
