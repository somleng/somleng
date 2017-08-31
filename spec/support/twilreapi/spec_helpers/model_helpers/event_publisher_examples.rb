shared_examples_for "event_publisher" do
  describe "events" do
    subject { create(factory, *traits) }
    let(:traits) { [] }

    def asserted_broadcast_event_name(event_type)
      [asserted_event_name, event_type].join("_")
    end

    context "create" do
      it("should broadcast") {
        assert_broadcasted!(asserted_broadcast_event_name(:created)) { subject }
      }
    end
  end
end
