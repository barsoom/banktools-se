require "banktools-se"

describe BankTools::SE::Bankgiro do

  it "should initialize" do
    BankTools::SE::Bankgiro.new("foo").should be_a(BankTools::SE::Bankgiro)
  end

end
