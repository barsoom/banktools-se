require "spec_helper"
require "banktools-se"

describe BankTools::SE::Bankgiro do

  it "should initialize" do
    BankTools::SE::Bankgiro.new("foo").should be_a(BankTools::SE::Bankgiro)
  end

  describe "#valid?" do

    it "should be true with no errors" do
      account = BankTools::SE::Bankgiro.new("foo")
      account.stub(:errors).and_return([])
      account.should be_valid
    end

    it "should be false with errors" do
      account = BankTools::SE::Bankgiro.new("foo")
      account.stub(:errors).and_return([:error])
      account.should_not be_valid
    end

  end

  describe "#errors" do
    # From http://www.carnegie.se/sv/Carnegie-fonder/Kopa-fonder/Bankgironummer/
    [
      "5402-9681",
      "297-3675",
      "640-5070",
    ].each do |number|
      it "should be empty for a valid number like #{number}" do
        BankTools::SE::Bankgiro.new(number).errors.should be_empty
      end
    end

    it "should include :too_short for numbers shorter than 7 digits" do
      BankTools::SE::Bankgiro.new(nil).errors.should include(BankTools::SE::Errors::TOO_SHORT)
      BankTools::SE::Bankgiro.new("").errors.should include(BankTools::SE::Errors::TOO_SHORT)
      BankTools::SE::Bankgiro.new("54-0296").errors.should include(BankTools::SE::Errors::TOO_SHORT)
      BankTools::SE::Bankgiro.new("54---------0296").errors.should include(BankTools::SE::Errors::TOO_SHORT)
    end

    it "should include :too_long for numbers longer than 8 digits" do
      BankTools::SE::Bankgiro.new("5402-96810").errors.should include(BankTools::SE::Errors::TOO_LONG)
    end

    it "should include :invalid_characters for numbers with other character than digits, spaces and dashes" do
      BankTools::SE::Bankgiro.new("5402-9681X").errors.should include(BankTools::SE::Errors::INVALID_CHARACTERS)
      BankTools::SE::Bankgiro.new(" 5 4 0 2 - 9 6 8 1 ").errors.should_not include(BankTools::SE::Errors::INVALID_CHARACTERS)
    end

    it "should include :bad_checksum if the Luhn/mod 10 checksum is incorrect" do
      BankTools::SE::Bankgiro.new("5402-9682").errors.should include(BankTools::SE::Errors::BAD_CHECKSUM)
    end

  end

  describe "#normalize" do

    it "should normalize 7-digit numbers to NNN-NNNN" do
      account = BankTools::SE::Bankgiro.new(" 6-40 - 5070")
      account.normalize.should == "640-5070"
    end

    it "should normalize 8-digit numbers to NNNN-NNNN" do
      account = BankTools::SE::Bankgiro.new(" 5-4-0-2-9-6- 81-  ")
      account.normalize.should == "5402-9681"
    end

    it "should not attempt to normalize invalid numbers" do
      account = BankTools::SE::Bankgiro.new(" 1-2-3 ")
      account.normalize.should == " 1-2-3 "
    end

  end

  describe "#fundraising? (90-konto)" do

    it "should be true for the number series 900-nnnn to 904-nnnn" do
      BankTools::SE::Bankgiro.new("902-0033").should be_fundraising
    end

    it "should be false for invalid numbers in the right series" do
      BankTools::SE::Bankgiro.new("902-0034").should_not be_fundraising
    end

    it "should be false for numbers outside the right series" do
      BankTools::SE::Bankgiro.new("5402-9681").should_not be_fundraising
    end

  end

end
