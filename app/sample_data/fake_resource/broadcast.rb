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

    enumerize :channel, in: [ :sms, :voice ]
    enumerize :status, in: [ :pending, :canceled, :in_progress, :completed ]

    class << self
      def model_name
        ActiveModel::Name.new(self, nil, "Broadcast")
      end

      def where(country_code: nil)
        DATA.fetch(country_code) { DATA.values.first }
      end

      def all
        DATA.values.flatten
      end

      def find(id)
        all.find(-> { raise(ActiveRecord::RecordNotFound) }) { _1.id == id }
      end
    end

    DATA = {
      "NP" => [
        new(
          id: "733bc4be-cd2d-4348-8ffd-9084cf39d309",
          channel: "voice",
          status: "pending",
          broadcaster: "DHM",
          headline: "Flood Warning for Sunsari District",
          message: "Heavy rainfall in the upstream areas of the Koshi River has caused rising water levels in the Sunsari and Saptari districts. Residents in low-lying areas along the Koshi River, including Haripur, Laukahi, and Barahakshetra, should exercise caution. Move valuables to higher ground and prepare for possible evacuation. Avoid walking or driving through floodwaters. If you must travel, use extreme caution and follow local authority instructions. Continue monitoring local radio and television broadcasts for further updates. For more information, please contact DHM at +977-1-5319052.",
          received_at: Time.current
        ),
        new(
          id: "c7c04749-c689-4834-ab72-97899c1f4431",
          channel: "voice",
          status: "in_progress",
          broadcaster: "DHM",
          headline: "Flood Alert for Kailali and Kanchanpur",
          message: "Due to continuous rainfall in the far-western region, the Mohana and Karnali rivers are rising rapidly. Flooding is expected in low-lying areas of Tikapur, Joshipur, and Bhajani (Kailali), and Shuklaphanta Municipality (Kanchanpur). Residents are advised to stay alert, avoid riverbanks, and keep livestock and belongings safe. Do not attempt to cross flooded roads or bridges. Local authorities may issue evacuation orders if water levels continue to rise. Stay tuned to local FM stations or contact DHM at +977-1-5319052 for updates.",
          started_by: "Saraswati Sharma",
          received_at: 24.hours.ago,
          started_at: 23.hours.ago
        ),
        new(
          id: "614f20b4-2cc8-4c7b-b703-6da7bd15ea8c",
          channel: "voice",
          status: "completed",
          broadcaster: "DHM",
          headline: "Flood Alert for Kailali and Kanchanpur",
          message: "A moderate earthquake has been reported near Barpak, Gorkha. Residents may experience aftershocks. Remain calm. If indoors, drop to your knees, cover your head and neck, and hold on to sturdy furniture. If on the ground floor of an old or weak house, exit quickly to an open area. If outdoors, move to a clear space away from buildings, trees, and power lines. If driving, pull over to a safe spot and remain inside the vehicle until the shaking stops. After the shaking, check for injuries, avoid damaged buildings, and listen to local media for official updates. For assistance, contact DHM at +977-1-5319052.",
          received_at: 48.hours.ago,
          started_at: 47.hours.ago,
          completed_at: 46.hours.ago,
          started_by: "Saraswati Sharma",
          completed_by: "Bikash Thapa"
        )
      ],
      "PK" => [
        new(
          id: "b827279c-486a-40a2-845a-30d38ada6ca5",
          channel: "sms",
          status: "pending",
          broadcaster: "NDMA",
          headline: "Flood warning for Punjab.",
          message: "Residents in low-lying areas should exercise caution. Avoid low areas. Persons should not be out on the roads during heavy rainfall. If you must be outside, use extreme caution. Do not drive your vehicle into areas where water covers the roadway. Vehicles caught in rising waters should be abandoned quickly. Continue listening to local media as updates will be provided if conditions change significantly. If you require additional information please contact NDMA at 051-111-157-157.",
          received_at: Time.current
        ),
        new(
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
        new(
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
        new(
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
    }.freeze
  end
end
