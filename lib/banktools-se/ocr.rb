# http://www.bgc.se/upload/Gemensamt/Trycksaker/Manualer/BG6070.pdf section 5.2

module BankTools
  module SE
    class OCR
      class InvalidOCR < StandardError; end
      class OverlongOCR < InvalidOCR; end
      class BadChecksum < InvalidOCR; end
      class MustBeNumeric < InvalidOCR; end

      MIN_LENGTH = 2
      MAX_LENGTH = 25

      def self.from_number(number, opts = {})
        number = number.to_s
        add_length_digit = opts.fetch(:length_digit, false)
        pad = opts.fetch(:pad, "").to_s

        raise MustBeNumeric unless number.match(/\A\d+\z/)
        # Padding isn't something BGC specifies, but we needed it to support a legacy scheme.
        number += pad
        # Adding 2: 1 length digit, 1 check digit.
        number += ((number.length + 2) % 10).to_s if add_length_digit

        number_with_ocr = number + Utils.luhn_checksum(number).to_s

        length = number_with_ocr.length
        if length > MAX_LENGTH
          raise OverlongOCR, "Bankgiro OCR must be #{MIN_LENGTH} - #{MAX_LENGTH} characters (this one would be #{length} characters)"
        end

        number_with_ocr
      end

      def self.to_number(number, opts = {})
        number = number.to_s
        strip_length_digit = opts.fetch(:length_digit, false)
        strip_padding = opts.fetch(:pad, "").to_s

        raise MustBeNumeric unless number.match(/\A\d+\z/)
        raise BadChecksum unless Utils.valid_luhn?(number)

        digits_to_chop  = 1  # Checksum.
        digits_to_chop += 1 if strip_length_digit
        digits_to_chop += strip_padding.length

        number[0...-digits_to_chop]
      end
    end
  end
end
