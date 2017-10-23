require 'rails_helper'
require Rails.root.join('db/application_seeder')

describe ApplicationSeeder do
  let(:initialization_options) { {} }
  subject { described_class.new(initialization_options) }

  describe "#seed!" do
    before do
      setup_scenario
    end

    def setup_scenario
      stub_env(env)
    end

    def env
      {}
    end

    def assert_seed!
      assert_outputs!(asserted_outputs) { subject.seed! }
      assert_user_account!
    end

    def assert_outputs!(asserted_outputs, &block)
      output_expectation =
      expect { yield }.to output(
        asserted_outputs.size > 1 ? Regexp.new(asserted_outputs.join(".+"), Regexp::MULTILINE) : asserted_outputs.first
    ).to_stdout
    end

    def assert_user_account!
      expect(Account.without_permissions.count).to eq(1)
    end

    context "by default" do
      def asserted_outputs
        ["User Account SID", "User Account Auth Token"]
      end

      context "without existing user account" do
        it { assert_seed! }
      end

      context "with existing user account" do
        let(:account) { create(:account) }

        def assert_seed!
          account
          super
        end

        def assert_user_account!
          super
          expect(Account.first).to eq(account)
        end

        it { assert_seed! }

        context "specifying FORMAT=basic_auth" do
          def asserted_outputs
            [/^#{account.sid}\:[\da-f]+$/]
          end

          def env
            super.merge("FORMAT" => "basic_auth")
          end

          it { assert_seed! }
        end
      end

      context "specifying ADMIN_ACCOUNT_PERMISSIONS=manage_inbound_phone_calls,manage_phone_call_events" do

        def env
          super.merge("ADMIN_ACCOUNT_PERMISSIONS" => "manage_inbound_phone_calls,manage_phone_call_events")
        end

        def asserted_outputs
          ["Admin Account SID", "Admin Account Auth Token"]
        end

        def assert_seed!
          super
          expect(Account.with_permissions(:manage_inbound_phone_calls, :manage_phone_call_events).count).to eq(1)
        end

        it { assert_seed! }

        context "specifying FORMAT=basic_auth OUTPUT=admin" do
          let(:account) {
            create(
              :account,
              :with_access_token,
              :permissions => [:manage_inbound_phone_calls, :manage_phone_call_events]
            )
          }

          def env
            super.merge("FORMAT" => "basic_auth", "OUTPUT" => "admin")
          end

          def asserted_outputs
            [[account.id, account.auth_token].join(":")]
          end

          def assert_seed!
            account
            super
          end

          it { assert_seed! }
        end
      end
    end
  end
end

