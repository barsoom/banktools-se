module BankTools
  module SE
    class Plusgiro

      # Could sadly not find anything more authoritative than
      #   http://pellesoft.se/communicate/forum/view.aspx?msgid=267449&forumid=63&sum=0
      #   https://www.nordea.se/foretag/kundservice/fragor-och-svar-konton.html#faq=Kontouppgifter+432454
      MAX_LENGTH = 10
      MIN_LENGTH = 2

      attr_reader :number

      def initialize(number)
        @number = number
      end

      def valid?
        errors.empty?
      end

      def errors
        errors = []

        errors << Errors::TOO_SHORT if digits.length < MIN_LENGTH
        errors << Errors::TOO_LONG if digits.length > MAX_LENGTH
        errors << Errors::INVALID_CHARACTERS if number.to_s.match(/[^0-9 -]/)
        errors << Errors::BAD_CHECKSUM unless Utils.valid_luhn?(number)

        errors
      end

      def normalize
        if valid?
          pre, pairs, post = digits.split(/(\d{2}*)(\d)$/)
          pairs = pairs.split(/(\d\d)/).reject(&:empty?)
          [ pre, pairs.join(" "), "-", post ].join
        else
          number
        end
      end

      # http://www.plusgirot.se/Om+PlusGirot/90-konton/508552.html
      # http://www.insamlingskontroll.se/
      def fundraising?
        valid? && digits.match(/\A90\d{5}$/)
      end

      private

      def digits
        number.to_s.gsub(/\D/, "")
      end

    end
  end
end
