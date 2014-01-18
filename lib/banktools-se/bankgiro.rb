# http://sv.wikipedia.org/wiki/Bankgirot#Bankgironummer

require "banktools-se/bankgiro/ocr"

module BankTools
  module SE
    class Bankgiro
      attr_reader :number

      def self.number_to_ocr(number, opts = {})
        OCR.number_to_ocr(number, opts)
      end

      def self.number_from_ocr(number, opts = {})
        OCR.number_from_ocr(number, opts)
      end

      def initialize(number)
        @number = number
      end

      def valid?
        errors.empty?
      end

      def errors
        errors = []

        errors << Errors::TOO_SHORT if digits.length < 7
        errors << Errors::TOO_LONG if digits.length > 8
        errors << Errors::INVALID_CHARACTERS if number.to_s.match(/[^0-9 -]/)
        errors << Errors::BAD_CHECKSUM unless BankTools::SE::Utils.valid_luhn?(number)

        errors
      end

      def normalize
        if valid?
          digits.split(/(\d{4})$/).join("-")
        else
          number
        end
      end

      def fundraising?
        valid? && digits.match(/\A90[0-4]/)
      end

      private

      def digits
        number.to_s.gsub(/\D/, '')
      end

    end
  end
end
