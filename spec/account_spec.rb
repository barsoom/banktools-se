# encoding: utf-8

require "spec_helper"
require "banktools-se"

describe BankTools::SE::Account do

  it "should initialize" do
    BankTools::SE::Account.new("foo").should be_a(BankTools::SE::Account)
  end

  describe "#valid?" do

    it "should be true with no errors" do
      account = BankTools::SE::Account.new("foo")
      account.stub!(:errors).and_return([])
      account.should be_valid
    end

    it "should be false with errors" do
      account = BankTools::SE::Account.new("foo")
      account.stub!(:errors).and_return([:error])
      account.should_not be_valid
    end

  end

  describe "#errors" do
    [
      "1100-0000000",       # Nordea.
      "1155-0000000",       # Nordea.
      "1199-0000000",       # Nordea.
      "1200-0000000",       # Danske Bank.
      "1400-0000000",       # Nordea.
      "2300-00",            # JP Nordiska.
      "2310-0000000",       # Ålandsbanken.
      "2311-00",            # JP Nordiska.
      "2950-00",            # Sambox.
      "3000-0000000",       # Nordea.
      "3300-800928-6249",   # Nordea personkonto.
      "3301-0000000",       # Nordea.
      "3400-0000000",       # Länsförsäkringar Bank.
      "3410-0000000",       # Nordea.
      "3782-800928-6249",   # Nordea personkonto.
      "3783-0000000",       # Nordea.
      "5000-0000000",       # SEB.
      "6000-000000000",     # Handelsbanken.
      "7000-0000000",       # Swedbank.
      "7121-0000000",       # Sparbanken i Enköping.
      "7123-0000000",       # Swedbank.
      "8000-2-0000000000",  # Swedbank/Sparbanker with clearing number checksum.
      "9020-0000000",       # Länsförsäkringar Bank.
      "9040-0000000",       # Citibank.
      "9050-00",            # HSB Bank.
      "9060-0000000",       # Länsförsäkringar Bank.
      "9080-00",            # Calyon Bank.
      "9090-00",            # ABN AMBRO.
      "9100-0000000",       # Nordnet Bank.
      "9120-0000000",       # SEB.
      "9130-0000000",       # SEB.
      "9150-0000000",       # Skandiabanken.
      "9170-0000000",       # Ikano Bank.
      "9180-0000000",       # Danske Bank.
      "9190-0000000",       # Den Norske Bank.
      "9200-00",            # Stadshypotek Bank.
      "9230-0000000",       # Bank2.
      "9231-00",            # SalusAnsvar Bank.
      "9260-00",            # Gjensidige NOR Sparebank.
      "9270-0000000",       # ICA Banken.
      "9280-0000000",       # Resurs Bank.
      "9290-00",            # Coop Bank.
      "9300-0000000000",    # Sparbanken Öresund.
      "9400-0000000",       # Forex Bank.
      "9460-0000000",       # GE Money Bank.
      "9469-0000000",       # GE Money Bank.
      "9500-0000000000",    # Plusgirot Bank.
      "9548-00",            # Ekobanken.
      "9549-00",            # JAK Medlemsbank.
      "9550-0000000",       # Avanza Bank.
      "9570-0000000000",    # Sparbanken Syd.
      "9960-0000000000",    # Plusgirot Bank.

    ].each do |number|
      it "should be empty for a valid number like #{number}" do
        BankTools::SE::Account.new(number).errors.should == []
      end
    end

    it "should include :too_short for numbers shorter than the bank allows" do
      BankTools::SE::Account.new("11007").errors.should include(BankTools::SE::Errors::TOO_SHORT)
    end

    it "should include :too_long for numbers longer than the bank allows" do
      BankTools::SE::Account.new("1100000000007").errors.should include(BankTools::SE::Errors::TOO_LONG)
    end

    it "should not include :too_long for Swedbank/Sparbanker numbers with clearing checksum" do
      BankTools::SE::Account.new("8000-2-0000000000").errors.should_not include(BankTools::SE::Errors::TOO_LONG)
    end

    it "should include :invalid_characters for numbers with other character than digits, spaces and dashes" do
      BankTools::SE::Account.new("1 2-3X").errors.should include(BankTools::SE::Errors::INVALID_CHARACTERS)
      BankTools::SE::Account.new("1 2-3").errors.should_not include(BankTools::SE::Errors::INVALID_CHARACTERS)
    end

    it "should include :bad_checksum for Nordea personkonto if the serial Luhn/mod 10 checksum is incorrect" do
      BankTools::SE::Utils.valid_luhn?("800928-6249").should be_true
      BankTools::SE::Utils.valid_luhn?("3300-800928-6249").should be_false
      BankTools::SE::Account.new("3300-800928-6249").errors.should_not include(BankTools::SE::Errors::BAD_CHECKSUM)
    end

    it "should include :unknown_clearing_number if the clearing number is unknown" do
      BankTools::SE::Account.new("10000000009").errors.should include(BankTools::SE::Errors::UNKNOWN_CLEARING_NUMBER)
      BankTools::SE::Account.new("11000000007").errors.should_not include(BankTools::SE::Errors::UNKNOWN_CLEARING_NUMBER)
    end

  end

  describe "#bank" do

    it "should return the bank for the current clearing number" do
      BankTools::SE::Account.new("11000000007").bank.should == "Nordea"
      BankTools::SE::Account.new("11550000001").bank.should == "Nordea"
      BankTools::SE::Account.new("11990000009").bank.should == "Nordea"
      BankTools::SE::Account.new("12000000005").bank.should == "Danske Bank"
    end

    it "should return nil for unknown clearing numbers" do
      BankTools::SE::Account.new("10000000009").bank.should be_nil
    end

  end

  describe "#clearing_number" do

    it "should be the first four digits" do
      BankTools::SE::Account.new("12345678").clearing_number.should == "1234"
    end

    it "should be the first five digits if there is a clearing number checksum" do
      BankTools::SE::Account.new("8000-2-0000000000").clearing_number.should == "8000-2"
    end

  end

  describe "#serial_number" do

    it "should be the digits after the first four digits" do
      BankTools::SE::Account.new("12345678").serial_number.should == "5678"
    end

    it "should be the digits after the first five digits if there is a clearing number checksum" do
      BankTools::SE::Account.new("8000-2-0000000000").serial_number.should == "0000000000"
    end

    it "should be the empty string if there aren't enough numbers" do
      BankTools::SE::Account.new("12").serial_number.should == ""
    end

  end

  describe "#normalize" do

    it "should normalize to clearing number dash serial number" do
      account = BankTools::SE::Account.new("11000000007").normalize.should == "1100-0000007"
    end

    it "should keep any Swedbank/Sparbanker clearing checksum" do
      BankTools::SE::Account.new("8000-2-0000000000").normalize.should == "8000-2-0000000000"
    end

    it "should not attempt to normalize invalid numbers" do
      account = BankTools::SE::Account.new(" 1-2-3 ").normalize.should == " 1-2-3 "
    end

  end

end
