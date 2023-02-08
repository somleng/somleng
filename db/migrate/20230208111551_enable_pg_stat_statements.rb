class EnablePgStatStatements < ActiveRecord::Migration[7.0]
  def change
    enable_extension("pg_stat_statements")
  end
end
