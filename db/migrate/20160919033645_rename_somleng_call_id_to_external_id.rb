class RenameSomlengCallIdToExternalId < ActiveRecord::Migration[5.0]
  def change
    rename_column(:phone_calls, :somleng_call_id, :external_id)
  end
end
