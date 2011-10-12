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

        errors << :too_short if digits.length < 7
        errors << :too_long if digits.length > 8
        errors << :invalid_characters if number.to_s.match(/[^0-9 -]/)
        errors << :bad_checksum unless BankTools::SE::Utils.valid_luhn?(number)

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
        valid? && number.match(/^90[0-4]/)
      end

      private

      def digits
        number.to_s.gsub(/\D/, '')
      end

    end
  end
end
