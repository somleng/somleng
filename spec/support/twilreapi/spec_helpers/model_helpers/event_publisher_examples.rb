shared_examples_for "event_publisher" do |params = {}|
  describe "events" do
    def asserted_broadcast_event_name(event_type)
      [asserted_event_name, event_type].join("_")
    end

    params[:events] ||= {
      :created => {
        :trigger => Proc.new { |_, factory| FactoryGirl.create(factory) }
      },
      :received => {
        :trigger => Proc.new { |subject| subject.received }
      }
    }

    params[:events].each do |event, event_params|
      context "#{event}" do
        it("should broadcast") {
          assert_broadcasted!(
            asserted_broadcast_event_name(event),
          ) { event_params[:trigger].call(subject, factory) }
        }
      end
    end
  end
end
