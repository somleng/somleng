class AddSequenceNumberColumns < ActiveRecord::Migration[6.1]
  def change
    tables = ApplicationRecord.connection.tables.reject { |t| ["schema_migrations", "ar_internal_metadata", "data_migrations", "active_storage_variant_records"].include?(t) }

    tables.each do |table_name|
      add_column table_name, :sequence_number, :bigserial, null: false
    end

    reversible do |dir|
      dir.up do
        tables.each do |table_name|
          execute <<-SQL
          UPDATE #{table_name} t
          SET sequence_number = ot.row_number
          FROM (SELECT id, ROW_NUMBER() OVER (ORDER BY created_at) FROM #{table_name}) ot
          WHERE t.id = ot.id
          SQL
        end
      end
    end

    tables.each do |table_name|
      add_index(table_name, :sequence_number, unique: true, order: :desc)
    end
  end
end
