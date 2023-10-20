class AddIndexOnTTSEventsTTSVoice < ActiveRecord::Migration[7.1]
  def change
    add_index(:tts_events, :tts_voice)
  end
end
