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

    context "queue adapter is configured" do
      let(:worker_queue) { "#{queue_adapter}_#{job_name}_queue" }

      def env
        {
          :"active_job_queue_adapter" => queue_adapter,
          :"active_job_#{queue_adapter}_#{job_name}_queue" => worker_queue
        }
      end

      def setup_scenario
        super
        stub_env(env)
      end

      if defined?(Sidekiq)
        context "sidekiq" do
          let(:queue_adapter) { "sidekiq" }
          let(:worker_class_name) { "Twilreapi::Sidekiq::MyWorker" }

          def env
            super.merge(:"active_job_#{queue_adapter}_#{job_name}_class" => worker_class_name)
          end

          def assert_enqueued!
            worker_class = worker_class_name.constantize
            enqueued_job = worker_class.jobs.first
            expect(enqueued_job["queue"]).to eq(worker_queue)
            expect(enqueued_job["class"]).to eq(worker_class_name)
            expect(enqueued_job["args"]).to match_array(args)
          end

          it { assert_enqueued! }
        end
      end

      if defined?(Shoryuken)
        context "shoryuken" do
          let(:queue_adapter) { "shoryuken" }
          let(:sqs_queue) { double('other queue') }

          def create_assertions!
            allow(Shoryuken::Client).to receive(:queues).with(worker_queue).and_return(sqs_queue)
            expect(sqs_queue).to receive(:send_message).with(*args)
          end

          def setup_scenario
            create_assertions!
            super
          end

          def assert_enqueued!
          end

          it { assert_enqueued! }
        end
      end
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
