# http://web.archive.org/web/20111216065227/http://www.bgc.se/upload/Gemensamt/Trycksaker/Manualer/BG6070.pdf section 5.2

module BankTools
  module SE
    class OCR
      class InvalidOCR < StandardError; end
      class OverlongOCR < InvalidOCR; end
      class BadPadding < InvalidOCR; end
      class BadLengthDigit < InvalidOCR; end
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
        should_have_length_digit = opts.fetch(:length_digit, false)
        strip_padding = opts.fetch(:pad, "").to_s

        raise MustBeNumeric unless number.match(/\A\d+\z/)
        raise BadChecksum unless Utils.valid_luhn?(number)

        if should_have_length_digit
          length_digit = number[-2]
          last_digit_of_actual_length = number.length.to_s[-1]
          raise BadLengthDigit if length_digit != last_digit_of_actual_length
        end

        digits_to_chop  = 1  # Checksum.
        digits_to_chop += 1 if should_have_length_digit

        if strip_padding.length > 0
          expected_padding_end = -digits_to_chop - 1
          expected_padding_start = expected_padding_end - strip_padding.length + 1
          raise BadPadding if number[expected_padding_start..expected_padding_end] != strip_padding
        end

        digits_to_chop += strip_padding.length

        number[0...-digits_to_chop]
      end
    end
  end
end
