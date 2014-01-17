# http://www.bgc.se/upload/Gemensamt/Trycksaker/Manualer/BG6070.pdf section 5.2

module BankTools
  module SE
    class Bankgiro
      class InvalidOCR < StandardError; end
      class OverlongOCR < InvalidOCR; end
      class BadChecksum < InvalidOCR; end

      class OCR
        def self.number_to_ocr(number, opts = {})
          add_length_digit = opts.fetch(:length_digit, false)
          pad = opts.fetch(:pad, nil)

          number = number.to_s

          number += pad if pad

          # Adding 2: 1 length digit, 1 check digit.
          number += ((number.length + 2) % 10).to_s if add_length_digit

          number_with_ocr = number + Utils.luhn_checksum(number).to_s

          length = number_with_ocr.length
          if length > 25
            raise OverlongOCR, "Bankgiro OCR must be 2-25 characters (this one would be #{length} characters)"
          end

          number_with_ocr
        end

        def self.number_from_ocr(number, opts = {})
          strip_length_digit = opts.fetch(:length_digit, false)
          strip_padding = opts.fetch(:pad, "")

          raise BadChecksum unless Utils.valid_luhn?(number)

          digits_to_chop  = 1  # Checksum.
          digits_to_chop += 1 if strip_length_digit
          digits_to_chop += strip_padding.length

          number[0...-digits_to_chop]
        end
      end
    end
  end
end
