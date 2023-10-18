require "rails_helper"

module TTSVoices
  module DataSource
    RSpec.describe PollyVoices do
      it "loads Polly voices" do
        fake_client = build_fake_polly_client
        voices = PollyVoices.new(aws_client: fake_client).load_data

        expect(voices.size).to eq(1)
        expect(voices.first).to have_attributes(
          gender: "Female",
          name: "Isabelle",
          language: "fr-BE",
          provider: have_attributes(
            name: "Polly"
          )
        )
      end

      def build_fake_polly_client
        Aws::Polly::Client.new(
          stub_responses: {
            describe_voices: {
              voices: [{ gender: "Female", id: "Isabelle", language_code: "fr-BE" }]
            }
          }
        )
      end
    end
  end
end
