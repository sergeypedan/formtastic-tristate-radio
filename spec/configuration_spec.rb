# frozen_string_literal: true

RSpec.describe FormtasticTristateRadio do

  describe ".configure" do
    it "is declared as a class method" do
      expect(described_class.methods).to include :configure
    end
  end

  describe ".config" do
    it "is declared as a class method" do
      expect(described_class).to respond_to :config
    end

    subject { described_class.config.unset_key }

    context "by default" do
      it "returns default value" do
        is_expected.to eq :null
      end
    end

    context "having set a custom value" do
      let(:new_value) { "test" }

      before(:each) do
        described_class.configure do |config|
          config.unset_key = new_value
        end
      end

      it "returns new value" do
        is_expected.to eq new_value
      end
    end
  end

end
