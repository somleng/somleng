require "rails_helper"

module SIPTrunks
  RSpec.describe ClientCredentialsCallbacks do
    it "generates client credentials" do
      sip_trunk = build(:sip_trunk, :client_credentials_authentication)

      sip_trunk.save!

      expect(sip_trunk.username).to be_present
      expect(sip_trunk.password.length).to eq(24)
    end

    it "handles duplicate usernames" do
      existing_sip_trunk = create(:sip_trunk, :client_credentials_authentication)
      fake_username_generator = instance_double(UsernameGenerator)
      unique_username = UsernameGenerator.new.random_username
      allow(fake_username_generator).to receive(:random_username).and_return(
        existing_sip_trunk.username, unique_username
      )

      sip_trunk = build(
        :sip_trunk,
        :client_credentials_authentication,
        username_generator: fake_username_generator
      )

      sip_trunk.save!

      expect(sip_trunk.username).to eq(unique_username)
    end

    it "resets the client credentials" do
      fake_call_service_client = build_fake_call_service_client
      sip_trunk = create(
        :sip_trunk,
        :client_credentials_authentication,
        call_service_client: fake_call_service_client
      )

      sip_trunk.update!(authentication_mode: :ip_address)

      expect(sip_trunk.username).to eq(nil)
      expect(sip_trunk.password).to eq(nil)
      expect(fake_call_service_client.subscribers.size).to eq(0)
    end

    it "creates a subscriber" do
      fake_call_service_client = build_fake_call_service_client
      sip_trunk = build(
        :sip_trunk,
        :client_credentials_authentication,
        call_service_client: fake_call_service_client
      )

      sip_trunk.save!

      expect(fake_call_service_client.subscribers.size).to eq(1)
    end

    it "deletes a subscriber" do
      fake_call_service_client = build_fake_call_service_client
      sip_trunk = create(
        :sip_trunk,
        :client_credentials_authentication,
        call_service_client: fake_call_service_client
      )

      sip_trunk.destroy!

      expect(fake_call_service_client.subscribers.size).to eq(0)
    end

    def build_fake_call_service_client
      klass = Class.new do
        attr_reader :subscribers

        def initialize
          @subscribers = []
        end

        def create_subscriber(username:, password:)
          _password = password
          subscribers << username
        end

        def delete_subscriber(username:)
          subscribers.delete(username)
        end
      end

      klass.new
    end
  end
end
