require 'rails_helper'

describe JobAdapter do
  let(:job_name) { "outbound_call_worker" }
  subject { described_class.new(job_name) }

  describe "#perform_later(*args)" do
    include Twilreapi::SpecHelpers::EnvHelpers
    include ActiveJob::TestHelper

    let(:args) { ["foo", "bar", 1] }
    let(:enqueued_job) { enqueued_jobs.first }
    let(:active_job_use_active_job) { "0" }
    let(:worker_queue) { "default" }

    def setup_scenario
    end

    before do
      setup_scenario
      subject.perform_later(*args)
    end

    def assert_active_job_enqueued!
      expect(enqueued_job[:job]).to eq(OutboundCallJob)
      expect(enqueued_job[:args]).to match_array(args)
      expect(enqueued_job[:queue]).to eq(worker_queue)
    end

    context "queue adapter is configured" do
      let(:worker_queue) { "#{active_job_queue_adapter}_#{job_name}_queue" }

      def env
        {
          :"active_job_queue_adapter" => active_job_queue_adapter,
          :"active_job_#{active_job_queue_adapter}_#{job_name}_queue" => worker_queue,
          :"active_job_use_active_job" => active_job_use_active_job
        }
      end

      def setup_scenario
        super
        stub_env(env)
      end

      if defined?(Sidekiq)
        context "sidekiq" do
          let(:active_job_queue_adapter) { "sidekiq" }
          let(:worker_class_name) { "Twilreapi::QueueAdapter::MyWorker" }

          def env
            super.merge(:"active_job_#{active_job_queue_adapter}_#{job_name}_class" => worker_class_name)
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
          let(:active_job_queue_adapter) { "shoryuken" }
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

      if defined?(ActiveElasticJob)
        context "active_elastic_job" do
          let(:active_job_queue_adapter) { "active_elastic_job" }
          let(:active_job_use_active_job) { "1" }

          it { assert_active_job_enqueued! }
        end
      end
    end

    context "no queue adapter is configured" do
      it { assert_active_job_enqueued! }
    end
  end
end
