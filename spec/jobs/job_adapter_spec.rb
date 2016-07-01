require 'rails_helper'

describe JobAdapter do
  let(:job_name) { "my_worker" }
  subject { described_class.new(job_name) }

  describe "#perform_later(*args)" do
    include Twilreapi::SpecHelpers::EnvHelpers

    let(:args) { ["foo", "bar", 1] }

    def setup_scenario
    end

    before do
      setup_scenario
      subject.perform_later(*args)
    end

    context "sidekiq is configured" do
      let(:sidekiq_worker_class_name) { "SidekiqMyWorker" }
      let(:sidekiq_worker_queue) { "sidekiq_my_worker_queue" }

      def setup_scenario
        super
        stub_env(
          :active_job_queue_adapter => "sidekiq",
          :active_job_sidekiq_my_worker_class => sidekiq_worker_class_name,
          :active_job_sidekiq_my_worker_queue => sidekiq_worker_queue
        )
      end

      def assert_enqueued!
        sidekiq_worker_class = sidekiq_worker_class_name.constantize
        enqueued_job = sidekiq_worker_class.jobs.first
        expect(enqueued_job["queue"]).to eq(sidekiq_worker_queue)
        expect(enqueued_job["class"]).to eq(sidekiq_worker_class_name)
        expect(enqueued_job["args"]).to match_array(args)
      end

      it { assert_enqueued! }
    end

    context "no queue adapter is configured" do
      include ActiveJob::TestHelper
      let(:enqueued_job) { enqueued_jobs.first }

      def assert_enqueued!
        expect(enqueued_job[:job]).to be <= ActiveJob::Base
        expect(enqueued_job[:args]).to match_array(args)
      end

      context "no worker class is configured" do
        it { assert_enqueued! }
      end

      context "a worker class is configured" do
        let(:active_job_class_name) { "FooJob" }

        def setup_scenario
          super
          stub_env(:active_job_my_worker_class => active_job_class_name)
        end

        context "and an ActiveJob is defined" do
          let(:active_job_class) { Object.const_set(active_job_class_name, Class.new(ActiveJob::Base)) }

          def setup_scenario
            super
            active_job_class
          end

          def assert_enqueued!
            super
            expect(enqueued_job[:job]).to eq(active_job_class)
          end

          it { assert_enqueued! }
        end
      end
    end
  end
end
