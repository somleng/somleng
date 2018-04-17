# frozen_string_literal: true

shared_examples_for 'event_publisher' do |params = {}|
  describe 'events' do
    def asserted_broadcast_event_name(event_type)
      [asserted_event_name, event_type].join('_')
    end

    params[:events] ||= {
      created: {
        trigger: proc { |_, factory| FactoryBot.create(factory) }
      },
      received: {
        trigger: proc { |subject| subject.received }
      }
    }

    params[:events].each do |event, event_params|
      context event.to_s do
        it('should broadcast') {
          assert_broadcasted!(
            asserted_broadcast_event_name(event)
          ) { event_params[:trigger].call(subject, factory) }
        }
      end
    end
  end
end
