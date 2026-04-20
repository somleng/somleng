class FixSlowQueryForQueuedCallsPerRegion < ActiveRecord::Migration[8.1]
  def change
    add_index(:phone_calls, [ :region ], where: "status = 'queued'")
  end
end
