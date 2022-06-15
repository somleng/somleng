class AddIndexOnPhoneCallsOnAccountIDAndStatus < ActiveRecord::Migration[7.0]
  def change
    add_index(:phone_calls, %i[account_id status], where: "(status = 'queued')")
  end
end
