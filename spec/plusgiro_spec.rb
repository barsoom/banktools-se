require "banktools-se"

RSpec.describe BankTools::SE::Plusgiro do

  it "should initialize" do
    expect(BankTools::SE::Plusgiro.new("foo")).to be_a(BankTools::SE::Plusgiro)
  end

  describe "#valid?" do

    it "should be true with no errors" do
      account = BankTools::SE::Plusgiro.new("foo")
      allow(account).to receive(:errors).and_return([])
      expect(account).to be_valid
    end

    it "should be false with errors" do
      account = BankTools::SE::Plusgiro.new("foo")
      allow(account).to receive(:errors).and_return([ :error ])
      expect(account).not_to be_valid
    end

  end

  describe "#errors" do
    [
      "28 65 43-4",  # IKEA
      "410 54 68-5",  # IKEA
      "4-2",  # Sveriges riksbank
    ].each do |number|
      it "should be empty for a valid number like #{number}" do
        expect(BankTools::SE::Plusgiro.new(number).errors).to be_empty
      end
    end

    it "should include :too_short for numbers shorter than 2 digits" do
      expect(BankTools::SE::Plusgiro.new(nil).errors).to include(BankTools::SE::Errors::TOO_SHORT)
      expect(BankTools::SE::Plusgiro.new("").errors).to include(BankTools::SE::Errors::TOO_SHORT)
      expect(BankTools::SE::Plusgiro.new("1").errors).to include(BankTools::SE::Errors::TOO_SHORT)
      expect(BankTools::SE::Plusgiro.new("1---------").errors).to include(BankTools::SE::Errors::TOO_SHORT)
    end

    it "should include :too_long for numbers longer than 8 digits" do
      expect(BankTools::SE::Plusgiro.new("410 54 68-51").errors).to include(BankTools::SE::Errors::TOO_LONG)
    end

    it "should include :invalid_characters for numbers with other character than digits, spaces and dashes" do
      expect(BankTools::SE::Plusgiro.new("410 54 68-5X").errors).to include(BankTools::SE::Errors::INVALID_CHARACTERS)
      expect(BankTools::SE::Plusgiro.new("4 1 0 5 4 6 8 - 5 ").errors).not_to include(BankTools::SE::Errors::INVALID_CHARACTERS)
    end

    it "should include :bad_checksum if the Luhn/mod 10 checksum is incorrect" do
      expect(BankTools::SE::Plusgiro.new("410 54 68-6").errors).to include(BankTools::SE::Errors::BAD_CHECKSUM)
    end

  end

  describe "#normalize" do

    it "should normalize short numbers to the format N-N" do
      account = BankTools::SE::Plusgiro.new(" 4 - 2")
      expect(account.normalize).to eq("4-2")
    end

    it "should normalize odd-length numbers to the format NN NN NN-N" do
      account = BankTools::SE::Plusgiro.new("2865434")
      expect(account.normalize).to eq("28 65 43-4")
    end

    it "should normalize even-length numbers to the format NNN NN NN-N" do
      account = BankTools::SE::Plusgiro.new("41054685")
      expect(account.normalize).to eq("410 54 68-5")
    end

    it "should not attempt to normalize invalid numbers" do
      account = BankTools::SE::Plusgiro.new(" 1-2-3 ")
      expect(account.normalize).to eq(" 1-2-3 ")
    end

  end

  describe "#fundraising? (90-konto)" do

    it "should be true for the number series 90-nnnn" do
      expect(BankTools::SE::Plusgiro.new("90 20 03-3")).to be_fundraising
    end

    it "should be false for invalid numbers in the right series" do
      expect(BankTools::SE::Plusgiro.new("90 20 03-4")).not_to be_fundraising
    end

    it "should be false for numbers outside the right series" do
      expect(BankTools::SE::Plusgiro.new("4-2")).not_to be_fundraising
    end

  end


end
