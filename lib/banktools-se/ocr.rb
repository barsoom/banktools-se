# http://web.archive.org/web/20111216065227/http://www.bgc.se/upload/Gemensamt/Trycksaker/Manualer/BG6070.pdf section 5.2

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

      # max_length is 19 because that's the longest allowed integer by default in a Postgres integer column with Ruby on Rails. So attempting some queries with longer OCRs may cause exceptions.
      def self.find_all_in_string(string, length_digit: false, pad: "", min_length: 4, max_length: 19)
        expanded_string = string + " " + string.gsub("\n", "") + " " + string.gsub(";", "")

        numbers = expanded_string.scan(/\d+/)

        expanded_numbers = with_numbers_found_by_removing_prefix_and_postfix(numbers).
          reject { |n| n.length < min_length || n.length > max_length }

        expanded_numbers.select { |candidate|
          begin
            to_number(candidate, length_digit: length_digit, pad: pad)
            true
          rescue InvalidOCR
            false
          end
        }.uniq
      end

      private

      private_class_method \
        def self.with_numbers_found_by_removing_prefix_and_postfix(numbers)
          numbers + numbers.flat_map { |number|
            0.upto(number.size).flat_map { |i|
              [
                number[0...i],
                number[i...number.size],
              ]
            }
          }
      end
    end
  end
end
