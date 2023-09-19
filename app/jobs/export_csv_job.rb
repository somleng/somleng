class ExportCSVJob < ApplicationJob
  queue_as AppSettings.config_for(:aws_sqs_long_running_queue_name)

  def perform(export)
    ExportCSV.call(export)
  end
end
