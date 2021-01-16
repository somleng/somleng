class AddDirectionToPhoneCalls < ActiveRecord::Migration[6.0]
  def change
    add_column :phone_calls, :direction, :string

    reversible do |dir|
      dir.up do
        PhoneCall.transaction do
          PhoneCall.where(incoming_phone_number_id: nil).update_all(direction: :outbound)
          PhoneCall.where.not(incoming_phone_number_id: nil).update_all(direction: :inbound)
          execute <<-SQL
            UPDATE "phone_calls" SET "to" = RIGHT("to", -1) WHERE ("to" ILIKE '+%');
            UPDATE "phone_calls" SET "from" = RIGHT("from", -1) WHERE ("from" ILIKE '+%');
          SQL
        end
      end
    end

    change_column_null :phone_calls, :direction, false
  end
end
