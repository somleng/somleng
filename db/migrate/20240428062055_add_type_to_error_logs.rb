class AddTypeToErrorLogs < ActiveRecord::Migration[7.1]
  def change
    add_column(:error_logs, :type, :string, null: false)
  end
end
