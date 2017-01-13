shared_examples_for "phone_number_attribute" do |options = {}|
  describe "validations" do
    it { is_expected.to validate_presence_of(phone_number_attribute) }

    if options[:validate_format] == false
      it { is_expected.to allow_value("+855970001294").for(phone_number_attribute) }
    else
      it { is_expected.to allow_value("+85512345676").for(phone_number_attribute) }
      it { is_expected.not_to allow_value("855123456768").for(phone_number_attribute) }
    end
  end

  describe "normalization" do
    let(:phone_number) { generate(:phone_number) }
    let(:asserted_normalized_phone_number) { "+" + phone_number }
    subject { create(factory, phone_number_attribute => phone_number) }

    it { expect(subject.public_send(phone_number_attribute)).to eq(asserted_normalized_phone_number) }
  end
end
