module SIPTrunks
  module ClientCredentialsCallbacks
    extend ActiveSupport::Concern

    included do
      before_save :generate_client_credentials
      after_create :create_subscriber
      after_destroy :delete_subscriber
      after_update :update_subscriber

      attribute :username_generator, default: UsernameGenerator.new
    end

    private

    def generate_client_credentials
      if authentication_mode.client_credentials?
        return if username.present?

        self.username = generate_username
        self.password = SecureRandom.alphanumeric(24)
      else
        self.username = nil
        self.password = nil
      end
    end

    def generate_username
      10.times do
        username = username_generator.random_username
        return username unless self.class.exists?(username:)
      end

      raise "Unable to generate unique username"
    end

    def create_subscriber
      return if username.blank?

      call_service_client.create_subscriber(username:, password:)
    end

    def delete_subscriber(username_to_delete: username)
      return if username_to_delete.blank?

      call_service_client.delete_subscriber(username: username_to_delete)
    end

    def update_subscriber
      old_username, new_username = previous_changes[:username]

      return if old_username == new_username

      delete_subscriber(username_to_delete: old_username)
      create_subscriber
    end
  end
end
