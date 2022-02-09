require "rails_helper"

RSpec.describe ScheduledJob do
  it "re-enqueues the job to run in 15 minutes from now if wait until is longer that 15 minutes" do
    travel_to(Time.zone.local(2018, 1, 1)) do
      job_args = ["AFakeJob", 1, { foo: "bar", wait_until: 15.minutes.from_now.to_f }]
      ScheduledJob.perform_now(*job_args)

      expect(
        ScheduledJob
      ).to have_been_enqueued.with(*job_args).at(Time.zone.local(2018, 1, 1, 0, 15))
    end
  end

  it "re-enqueues the job to run in 14 minutes from now" do
    travel_to(Time.zone.local(2018, 1, 1)) do
      job_args = ["AFakeJob", 1, { foo: "bar", wait_until: 14.minutes.from_now.to_f }]
      ScheduledJob.perform_now(*job_args)

      expect(
        ScheduledJob
      ).to have_been_enqueued.with(*job_args).at(Time.zone.local(2018, 1, 1, 0, 14))
    end
  end

  it "runs the job immediately when the scheduled_at is in the past" do
    stub_const("ScheduledJob::FakeJob", Class.new(ApplicationJob))
    ScheduledJob.perform_now("ScheduledJob::FakeJob", 1, { foo: "bar", wait_until: 1.second.ago.to_f })

    expect(ScheduledJob).not_to have_been_enqueued
    expect(ScheduledJob::FakeJob).to have_been_enqueued.with(1, foo: "bar")
  end

  it "only passes through the original job args to the executing job" do
    stub_const("ScheduledJob::FakeJob", Class.new(ApplicationJob))
    ScheduledJob.perform_now("ScheduledJob::FakeJob", 1, nil, 2, wait_until: 1.second.ago.to_f)

    expect(ScheduledJob::FakeJob).to have_been_enqueued.with(1, nil, 2)
  end
end
