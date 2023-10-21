class AddProviderAndEngineToTTSEvents < ActiveRecord::Migration[7.1]
  def change
    add_column(:tts_events, :tts_provider, :string)
    add_column(:tts_events, :tts_engine, :string)
    add_index(:tts_events, :tts_provider)
    add_index(:tts_events, :tts_engine)

    reversible do |dir|
      dir.up do
        TTSEvent.where("tts_voice ilike ?", "%Basic%").update_all(tts_provider: "Basic",
                                                                  tts_engine: "Standard")
        TTSEvent.where("tts_voice ilike ?", "%Polly%").update_all(tts_provider: "Polly",
                                                                  tts_engine: "Standard")
        TTSEvent.where("tts_voice ilike ?", "%Neural%").update_all(tts_engine: "Neural")
      end
    end

    change_column_null(:tts_events, :tts_provider, false)
    change_column_null(:tts_events, :tts_engine, false)
  end
end
