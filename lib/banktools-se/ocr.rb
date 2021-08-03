# https://www.bankgirot.se/globalassets/dokument/anvandarmanualer/bankgiroinbetalningar_anvandarmanual_sv_31okt2016.pdf section 5.2

module BankTools
  module SE
    class OCR
      class InvalidOCR < StandardError; end
      class OverlongOCR < InvalidOCR; end
      class TooShortOCR < InvalidOCR; end
      class BadPadding < InvalidOCR; end
      class BadLengthDigit < InvalidOCR; end
      class BadChecksum < InvalidOCR; end
      class MustBeNumeric < InvalidOCR; end

      MIN_LENGTH = 2
      MAX_LENGTH = 25

      def self.from_number(number, length_digit: false, pad: "")
        number = number.to_s
        add_length_digit = length_digit
        pad = pad.to_s

        raise MustBeNumeric unless number.match(/\A\d+\z/)

        # Padding isn't something BGC specifies, but we needed it to support a legacy scheme.
        number += pad
        # Adding 2: 1 length digit, 1 check digit.
        number += ((number.length + 2) % 10).to_s if add_length_digit

        number_with_ocr = number + Utils.luhn_checksum(number).to_s

        length = number_with_ocr.length
        if length > MAX_LENGTH
          raise OverlongOCR, "OCR must be #{MIN_LENGTH} - #{MAX_LENGTH} characters (this one would be #{length} characters)"
        end

        number_with_ocr
      end

      def self.to_number(ocr, length_digit: false, pad: "")
        ocr = ocr.to_s
        should_have_length_digit = length_digit
        strip_padding = pad.to_s

        raise MustBeNumeric unless ocr.match(/\A\d+\z/)
        raise BadChecksum unless Utils.valid_luhn?(ocr)
        raise TooShortOCR if ocr.length < MIN_LENGTH

        if should_have_length_digit
          length_digit = ocr[-2]
          last_digit_of_actual_length = ocr.length.to_s[-1]
          raise BadLengthDigit if length_digit != last_digit_of_actual_length
        end

        digits_to_chop  = 1  # Checksum.
        digits_to_chop += 1 if should_have_length_digit

        if strip_padding.length > 0
          expected_padding_end = -digits_to_chop - 1
          expected_padding_start = expected_padding_end - strip_padding.length + 1
          raise BadPadding if ocr[expected_padding_start..expected_padding_end] != strip_padding
        end

        digits_to_chop += strip_padding.length

        ocr[0...-digits_to_chop]
      end

      # max_length is 18, because the biggest allowed integer by default in a Postgres integer column ("bigint") is 19 digits long, as is the next (disallowed) number. Attempting some queries with longer OCRs may cause Ruby on Rails exceptions.
      def self.find_all_in_string(string, length_digit: false, pad: "", min_length: 4, max_length: 18)
        # First, treat the input as one long string of digits.
        # E.g. "1234 and 5678" becomes "12345678".

        digit_string = string.gsub(/\D/, "")

        # Then find all substrings ("n-grams") of min_length, and of all other lengths, up to max_length.
        # So e.g. find all four-digit substrings ("1234", "2345", …), all five-digit substrings and so on.

        digit_string_length = digit_string.length
        candidates = []

        0.upto(digit_string.length - min_length) do |start_pos|
          min_end_pos = start_pos + min_length - 1
          max_end_pos = [ start_pos + max_length, digit_string_length ].min - 1

          min_end_pos.upto(max_end_pos) do |end_pos|
            candidates << digit_string.slice(start_pos..end_pos)
          end
        end

        # Get rid of any duplicates.

        candidates = candidates.uniq

        # Finally, limit these substrings to ones that are actually valid OCRs.

        candidates.select { |candidate|
          begin
            to_number(candidate, length_digit: length_digit, pad: pad)
            true
          rescue InvalidOCR
            false
          end
        }
      end
    end
  end
end
