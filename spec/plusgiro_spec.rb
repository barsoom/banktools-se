require "banktools-se"

describe BankTools::SE::Plusgiro do

  it "should initialize" do
    BankTools::SE::Plusgiro.new("foo").should be_a(BankTools::SE::Plusgiro)
  end

  describe "#valid?" do

    it "should be true with no errors" do
      account = BankTools::SE::Plusgiro.new("foo")
      account.stub!(:errors).and_return([])
      account.should be_valid
    end

    it "should be false with errors" do
      account = BankTools::SE::Plusgiro.new("foo")
      account.stub!(:errors).and_return([:error])
      account.should_not be_valid
    end

  end

  describe "#errors" do
    [
      "28 65 43-4",  # IKEA
      "410 54 68-5",  # IKEA
      "4-2",  # Sveriges riksbank
    ].each do |number|
      it "should be empty for a valid number like #{number}" do
        BankTools::SE::Plusgiro.new(number).errors.should be_empty
      end
    end

    it "should include :too_short for numbers shorter than 2 digits" do
      BankTools::SE::Plusgiro.new(nil).errors.should include(:too_short)
      BankTools::SE::Plusgiro.new("").errors.should include(:too_short)
      BankTools::SE::Plusgiro.new("1").errors.should include(:too_short)
      BankTools::SE::Plusgiro.new("1---------").errors.should include(:too_short)
    end

    it "should include :too_long for numbers longer than 8 digits" do
      BankTools::SE::Plusgiro.new("410 54 68-51").errors.should include(:too_long)
    end

    it "should include :invalid_characters for numbers with other character than digits, spaces and dashes" do
      BankTools::SE::Plusgiro.new("410 54 68-5X").errors.should include(:invalid_characters)
      BankTools::SE::Plusgiro.new("4 1 0 5 4 6 8 - 5 ").errors.should_not include(:invalid_characters)
    end

    it "should include :bad_checksum if the Luhn/mod 10 checksum is incorrect" do
      BankTools::SE::Plusgiro.new("410 54 68-6").errors.should include(:bad_checksum)
    end

  end

  describe "#normalize" do

    it "should normalize short numbers to the format N-N" do
      account = BankTools::SE::Plusgiro.new(" 4 - 2")
      account.normalize.should == "4-2"
    end

    it "should normalize odd-length numbers to the format NN NN NN-N" do
      account = BankTools::SE::Plusgiro.new("2865434")
      account.normalize.should == "28 65 43-4"
    end

    it "should normalize even-length numbers to the format NNN NN NN-N" do
      account = BankTools::SE::Plusgiro.new("41054685")
      account.normalize.should == "410 54 68-5"
    end

    it "should not attempt to normalize invalid numbers" do
      account = BankTools::SE::Plusgiro.new(" 1-2-3 ")
      account.normalize.should == " 1-2-3 "
    end

  end

  describe "#fundraising? (90-konto)" do

    it "should be true for the number series 90-nnnn" do
      BankTools::SE::Plusgiro.new("90 20 03-3").should be_fundraising
    end

    it "should be false for invalid numbers in the right series" do
      BankTools::SE::Plusgiro.new("90 20 03-4").should_not be_fundraising
    end

    it "should be false for numbers outside the right series" do
      BankTools::SE::Plusgiro.new("4-2").should_not be_fundraising
    end

  end


end
