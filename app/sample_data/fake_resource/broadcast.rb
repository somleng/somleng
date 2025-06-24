module FakeResource
  class Broadcast
    include ActiveModel::Model
    include ActiveModel::Attributes

    extend Enumerize

    attribute :id
    attribute :channel
    attribute :status
    attribute :broadcaster
    attribute :headline
    attribute :message
    attribute :started_by
    attribute :completed_by
    attribute :received_at, :datetime
    attribute :started_at, :datetime
    attribute :completed_at, :datetime
    attribute :canceled_at, :datetime

    enumerize :channel, in: [ :sms ]
    enumerize :status, in: [ :pending, :canceled, :in_progress, :completed ]

    def model_name
      ActiveModel::Name.new(self, nil, "Broadcast")
    end

    class << self
      def all
        @broadcasts ||= [
          Broadcast.new(
            id: "b827279c-486a-40a2-845a-30d38ada6ca5",
            channel: "sms",
            status: "pending",
            broadcaster: "NDMA",
            headline: "Flood warning for Punjab.",
            message: "Residents in low-lying areas should exercise caution. Avoid low areas. Persons should not be out on the roads during heavy rainfall. If you must be outside, use extreme caution. Do not drive your vehicle into areas where water covers the roadway. Vehicles caught in rising waters should be abandoned quickly. Continue listening to local media as updates will be provided if conditions change significantly. If you require additional information please contact NDMA at 051-111-157-157.",
            received_at: Time.current
          ),
          Broadcast.new(
            id: "46d79566-2572-455b-9d20-2de354e84eca",
            channel: "sms",
            status: "in_progress",
            broadcaster: "NDMA",
            headline: "Extreme heat warning for Jacobabad.",
            message: "Avoid direct exposure to the sun. Protect yourself with lightweight, loose-fitting clothing. Stay hydrated. Cool yourself down. Check with your neighbors, friends, and those at risk.",
            started_by: "Asif Aziz",
            received_at: 24.hours.ago,
            started_at: 23.hours.ago
          ),
          Broadcast.new(
            id: "9f648176-8b43-484d-a291-4cb28b2d4b90",
            channel: "sms",
            broadcaster: "NDMA",
            headline: "Earthquake warning for Balochistan.",
            message: "Remain calm. If indoors, drop to your knees, cover your head and neck, and hold on to your cover. If on the ground floor of an adobe house with a heavy roof, exit quickly. If outdoors, find a clear spot and drop to your knees to prevent falling. If in a vehicle, go to a clear location and pull over. After the main shaking stops, if you are indoors, move cautiously and evacuate the building. Expect aftershocks.",
            status: "completed",
            started_by: "Khalid Shehzad",
            completed_by: "Aamir Ibrahim",
            received_at: 48.hours.ago,
            started_at: 47.hours.ago,
            completed_at: 46.hours.ago
          ),
          Broadcast.new(
            id: "17c21e2f-110c-4e44-876c-d08f57b73797",
            channel: "sms",
            broadcaster: "NDMA",
            headline: "Flood warning for Azad Kashmir.",
            message: "Residents in low-lying areas should exercise caution. Avoid low areas. Persons should not be out on the roads during heavy rainfall. If you must be outside, use extreme caution. Do not drive your vehicle into areas where water covers the roadway. Vehicles caught in rising waters should be abandoned quickly. Continue listening to local media as updates will be provided if conditions change significantly. If you require additional information please contact NDMA at 051-111-157-157.",
            status: "canceled",
            received_at: 72.hours.ago,
            canceled_at: 71.hours.ago
          )
        ]
      end

      def find(id)
        all.find(-> { raise(ActiveRecord::RecordNotFound) }) { _1.id == id }
      end
    end
  end
end
