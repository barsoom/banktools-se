require "spec_helper"
require "banktools-se"

describe BankTools::SE::OCR do
  # http://web.archive.org/web/20111216065227/http://www.bgc.se/upload/Gemensamt/Trycksaker/Manualer/BG6070.pdf section 5.2
  describe ".from_number" do
    it "adds a mod-10 check digit" do
      BankTools::SE::OCR.from_number("123").should eq "1230"
    end

    it "handles integer input" do
      BankTools::SE::OCR.from_number(123).should eq "1230"
    end

    it "can add an optional length digit" do
      BankTools::SE::OCR.from_number("1234567890", length_digit: true).should eq "123456789023"
    end

    it "can pad the number" do
      BankTools::SE::OCR.from_number("1234567890", length_digit: true, pad: "0").should eq "1234567890037"
    end

    it "raises if resulting number is > 25 digits" do
      expect { BankTools::SE::OCR.from_number("1234567890123456789012345") }.to raise_error(BankTools::SE::OCR::OverlongOCR)
    end

    it "raises if input is non-numeric" do
      expect { BankTools::SE::OCR.from_number("garbage") }.to raise_error(BankTools::SE::OCR::MustBeNumeric)
    end
  end

  describe ".to_number" do
    it "strips the mod-10 check digit" do
      BankTools::SE::OCR.to_number("1230").should eq "123"
    end

    it "handles integer input" do
      BankTools::SE::OCR.to_number(1230).should eq "123"
    end

    it "can strip an optional length digit" do
      BankTools::SE::OCR.to_number("123456789023", length_digit: true).should eq "1234567890"
    end

    it "strips the given padding" do
      BankTools::SE::OCR.to_number("1234567890037", length_digit: true, pad: "0").should eq "1234567890"
    end

    it "raises if the given number is too short to be a valid OCR" do
      expect { BankTools::SE::OCR.to_number("0") }.to raise_error(BankTools::SE::OCR::TooShortOCR)
      expect { BankTools::SE::OCR.to_number("00") }.not_to raise_error
    end

    it "raises if checksum is wrong" do
      expect { BankTools::SE::OCR.to_number("1231") }.to raise_error(BankTools::SE::OCR::BadChecksum)
    end

    it "raises if length digit is wrong" do
      expect { BankTools::SE::OCR.to_number("12369", length_digit: true) }.to raise_error(BankTools::SE::OCR::BadLengthDigit)
    end

    it "raises if padding doesn't match the given value" do
      expect { BankTools::SE::OCR.to_number("1230", pad: "") }.not_to raise_error
      expect { BankTools::SE::OCR.to_number("12302", pad: "0") }.not_to raise_error
      expect { BankTools::SE::OCR.to_number("1230002", pad: "000") }.not_to raise_error

      expect { BankTools::SE::OCR.to_number("12344", pad: "0") }.to raise_error(BankTools::SE::OCR::BadPadding)
    end

    it "raises if input is non-numeric" do
      expect { BankTools::SE::OCR.to_number("garbage") }.to raise_error(BankTools::SE::OCR::MustBeNumeric)
    end
  end

  describe ".find_all_in_string" do
    it "detects only number sequences that are valid OCRs" do
      expect(BankTools::SE::OCR.find_all_in_string("1230 1234 4564")).to eq [ "1230", "4564" ]
    end

    it "requires OCRs to comply with the specified length_digit and pad options" do
      string = "1230 4564 123067 456061"
      expect(BankTools::SE::OCR.find_all_in_string(string)).to eq [ "1230", "4564", "123067", "456061" ]
      expect(BankTools::SE::OCR.find_all_in_string(string, length_digit: true, pad: "0")).to eq [ "123067", "456061" ]
    end

    it "finds digits among any non-digit characters" do
      expect(BankTools::SE::OCR.find_all_in_string("x1230x")).to eq [ "1230" ]
    end

    it "handles OCR numbers both separated and split by newlines" do
      expect(BankTools::SE::OCR.find_all_in_string("1230\n4564")).to include "1230", "4564", "12304564"
      expect(BankTools::SE::OCR.find_all_in_string("45\n64")).to eq [ "4564" ]
    end

    it "handles OCR numbers both separated and split by semicolons" do
      expect(BankTools::SE::OCR.find_all_in_string("1230;4564")).to include "1230", "4564", "12304564"
      expect(BankTools::SE::OCR.find_all_in_string("45;64")).to eq [ "4564" ]
    end

    it "handles OCR numbers both separated and split by '.'" do
      expect(BankTools::SE::OCR.find_all_in_string("1230.4564")).to include "1230", "4564", "12304564"
      expect(BankTools::SE::OCR.find_all_in_string("45.64")).to eq [ "4564" ]
    end

    it "handles numbers smushed together" do
      # "Ref 1: 1230" with characters gone missing.
      expect(BankTools::SE::OCR.find_all_in_string("REF 11230")).to include "1230"

      # Two OCRs without separation.
      expect(BankTools::SE::OCR.find_all_in_string("12304564")).to include "1230", "4564"

      # Amount smushed into OCR.
      expect(BankTools::SE::OCR.find_all_in_string("EHRENKRONAAUFTR: EUR 17,183188720001 PAYMENT")).to include "3188720001"

      # OCR smushed into item ID.
      string = "Referenznummer 3201675000187604. HISTORISTISCHER SALONTISCH."
      expect(BankTools::SE::OCR.find_all_in_string(string)).to include "3201675000"
    end

    it "lets you configure the accepted OCR min_length" do
      expect(BankTools::SE::OCR.find_all_in_string("12304564")).to eq [ "12304564", "04564", "1230", "4564" ]
      expect(BankTools::SE::OCR.find_all_in_string("12304564", min_length: 6)).to eq [ "12304564" ]

      expect(BankTools::SE::OCR.find_all_in_string("1234")).to eq []
      expect(BankTools::SE::OCR.find_all_in_string("1234", min_length: 2)).to eq [ "34" ]
    end

    it "lets you configure the accepted OCR max_length" do
      ocr_length_19 = "1234567890123456785"
      ocr_length_20 = "12345678901234567894"
      string = "#{ocr_length_19} #{ocr_length_20}"

      # Default max_length is 19.
      expect(BankTools::SE::OCR.find_all_in_string(string)).to include ocr_length_19
      expect(BankTools::SE::OCR.find_all_in_string(string)).not_to include ocr_length_20

      expect(BankTools::SE::OCR.find_all_in_string(string, max_length: 20)).to include ocr_length_19, ocr_length_20
    end

    it "excludes duplicates" do
      expect(BankTools::SE::OCR.find_all_in_string("1230 1230 4564")).to eq [ "1230", "4564" ]
    end
  end
end
