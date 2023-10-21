class AddProviderAndEngineToTTSEvents < ActiveRecord::Migration[7.1]
  def change
    add_column(:tts_events, :tts_provider, :string, null: false)
    add_column(:tts_events, :tts_engine, :string, null: false)
    add_index(:tts_events, :tts_provider)
    add_index(:tts_events, :tts_engine)
  end
end
