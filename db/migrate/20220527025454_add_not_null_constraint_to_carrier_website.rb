class AddNotNullConstraintToCarrierWebsite < ActiveRecord::Migration[7.0]
  def change
    change_column_null(:carriers, :website, false)
  end
end
