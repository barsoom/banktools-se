module BankTools
  module SE
    class Bankgiro

      # http://sv.wikipedia.org/wiki/Bankgirot#Bankgironummer

      attr_reader :number

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
        valid? && digits.match(/^90[0-4]/)
      end

      private

      def digits
        number.to_s.gsub(/\D/, '')
      end

    end
  end
end
