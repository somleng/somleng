require "rails_helper"

module TTSVoices
  module DataSource
    RSpec.describe BasicVoices do
      it "loads Basic voices" do
        voices = BasicVoices.new.load_data

        expect(voices.size).to eq(2)
        expect(voices.first).to have_attributes(
          gender: "Male",
          name: "Kal",
          language: "en-us",
          provider: have_attributes(
            name: "Basic"
          )
        )
      end
    end
  end
end
