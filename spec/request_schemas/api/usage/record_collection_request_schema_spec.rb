require "rails_helper"

module API
  module Usage
    RSpec.describe RecordCollectionRequestSchema, type: :request_schema do
      it { expect(validate_schema(Category: nil)).not_to have_valid_field(:Category) }
      it { expect(validate_schema(Category: "foo")).not_to have_valid_field(:Category) }
      it { expect(validate_schema(Category: "calls")).to have_valid_field(:Category) }
      it { expect(validate_schema(Category: "calls-inbound")).to have_valid_field(:Category) }
      it { expect(validate_schema(Category: "calls-outbound")).to have_valid_field(:Category) }

      it { expect(validate_schema(StartDate: nil)).not_to have_valid_field(:StartDate) }
      it { expect(validate_schema(StartDate: "foo")).not_to have_valid_field(:StartDate) }
      it { expect(validate_schema(StartDate: "2012-09-31")).not_to have_valid_field(:StartDate) }
      it { expect(validate_schema(StartDate: "2012-09-01")).to have_valid_field(:StartDate) }
      it { expect(validate_schema(StartDate: "20120901")).to have_valid_field(:StartDate) }

      it { expect(validate_schema(EndDate: nil)).not_to have_valid_field(:EndDate) }
      it { expect(validate_schema(EndDate: "foo")).not_to have_valid_field(:EndDate) }
      it { expect(validate_schema(EndDate: "2012-09-31")).not_to have_valid_field(:EndDate) }
      it { expect(validate_schema(EndDate: "2012-09-01")).to have_valid_field(:EndDate) }
      it { expect(validate_schema(EndDate: "20120901")).to have_valid_field(:EndDate) }
    end
  end
end
