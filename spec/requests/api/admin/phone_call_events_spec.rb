require 'rails_helper'

describe "'/api/admin/phone_calls/:phone_call_external_id/phone_call_events'" do
  let(:phone_call) {
    create(
      :phone_call,
      :initiated,
      :with_external_id,
      :with_status_callback_url,
      :from_account_with_access_token
    )
  }

  def account_params
    super.merge(:permissions => [:manage_phone_call_events])
  end

  def setup_scenario
  end

  before do
    setup_scenario
  end

  describe "GET '/:id'" do
    let(:phone_call_event) { create(:phone_call_event, :phone_call => phone_call) }

    def get_phone_call_event
      do_request(:get, api_admin_phone_call_phone_call_event_path(phone_call, phone_call_event))
    end

    def setup_scenario
      super
      get_phone_call_event
    end

    context "unauthorized request" do
      def account_params
        super.merge(:permissions => [])
      end

      it { assert_unauthorized! }
    end

    context "valid request" do
      def assert_valid_request!
        expect(response.code).to eq("200")
      end

      it { assert_valid_request! }
    end
  end

  describe "POST '/'" do
    def params
      {}
    end

    def post_phone_call_event
      do_request(
        :post,
        api_admin_phone_call_phone_call_events_path(phone_call.external_id),
        params
     )
    end

    def setup_scenario
      super
      post_phone_call_event
    end

    context "unauthorized request" do
      def account_params
        super.merge(:permissions => [])
      end

      it { assert_unauthorized! }
    end

    context "authorized request" do
      let(:event_type) { nil }

      context "invalid request" do
        def assert_invalid_request!
          expect(response.code).to eq("422")
        end

        it { assert_invalid_request! }
      end

      context "valid requests" do
        let(:response_json) { JSON.parse(response.body) }
        let(:created_event) { phone_call.phone_call_events.last! }

        def params
          super.merge(
            :type => event_type
          )
        end

        def assert_valid_request!
          expect(response.code).to eq("201")
          expect(response.body).to be_empty
          expect(response.headers["Location"]).to eq(api_admin_phone_call_phone_call_event_path(phone_call, created_event))
        end

        context "recording_completed" do
          let(:event_type) { "recording_completed" }
          let(:recording_duration) { "8999" }
          let(:recording_size) { "0" }
          let(:recording_uri) { "file:///var/lib/freeswitch/recordings/1dff035b-10d6-419d-9c60-643b651ef096-2.wav" }

          def params
            super.merge(
              :recording_duration => recording_duration,
              :recording_size => recording_size,
              :recording_uri => recording_uri
            )
          end

          def assert_valid_request!
            super
            expect(created_event.recording_duration).to eq(recording_duration)
            expect(created_event.recording_size).to eq(recording_size)
            expect(created_event.recording_uri).to eq(recording_uri)
          end

          it { assert_valid_request! }
        end

        context "completed" do
          let(:event_type) { "completed" }
          let(:answer_epoch) { "1" }
          let(:sip_term_status) { "480" }

          def params
            super.merge(
              :answer_epoch => answer_epoch,
              :sip_term_status => sip_term_status
            )
          end

          def setup_scenario
            stub_request(:post, phone_call.status_callback_url)
            super
          end

          def post_phone_call_event
            perform_enqueued_jobs { super }
          end

          def assert_valid_request!
            super
            expect(created_event.answer_epoch).to eq(answer_epoch)
            expect(created_event.sip_term_status).to eq(sip_term_status)
            expect(phone_call.reload).to be_completed
            expect(WebMock).to have_requested(
              :post, phone_call.status_callback_url
            )
          end

          it { assert_valid_request! }
        end
      end
    end
  end
end
