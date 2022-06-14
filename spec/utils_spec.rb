require "spec_helper"
require "banktools-se/utils"

RSpec.describe BankTools::SE::Utils, "valid_luhn?" do

  [
    "00",
    "18",
    "26",
    "34",
    "42",
    "59",
    "67",
    "75",
    "83",
    "91",
    "109",
    "117",
    "5402-9681",
  ].each do |number|
    it "should allow a valid number like #{number}" do
      expect(BankTools::SE::Utils.valid_luhn?(number)).to eq(true)
    end
  end

  [
    "01",
    "118",
    "5402-9682",
  ].each do |number|
    it "should disallow an invalid number like #{number}" do
      expect(BankTools::SE::Utils.valid_luhn?(number)).to eq(false)
    end
  end

end
