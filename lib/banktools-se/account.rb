# encoding: utf-8

# https://www.bankgirot.se/globalassets/dokument/anvandarmanualer/bankernaskontonummeruppbyggnad_anvandarmanual_sv.pdf

require "banktools-se/account/clearing_number"

module BankTools
  module SE
    class Account
      DEFAULT_SERIAL_NUMBER_LENGTH = 7
      CLEARING_NUMBER_MAP = ClearingNumber::MAP

      attr_reader :number

      def initialize(number)
        @number = number
      end

      def valid?
        errors.empty?
      end

      def errors
        errors = []

        errors << Errors::TOO_SHORT if serial_number.length < min_length
        errors << Errors::TOO_LONG if serial_number.length > max_length
        errors << Errors::INVALID_CHARACTERS if number.to_s.match(/[^\d -]/)

        if luhn_for_serial?
          errors << Errors::BAD_CHECKSUM unless Utils.valid_luhn?(serial_number)
        end

        errors << Errors::UNKNOWN_CLEARING_NUMBER unless bank

        errors
      end

      def normalize
        if valid?
          [ clearing_number, serial_number ].join("-")
        else
          number
        end
      end

      def bank
        bank_data[:name]
      end

      def clearing_number
        [
          digits[0, 4],
          checksum_for_clearing? ? digits[4, 1] : nil,
        ].compact.join("-")
      end

      def serial_number
        number = digits.slice(clearing_number_length..-1) || ""

        if zerofill?
          number.rjust(serial_number_length, "0")
        else
          number
        end
      end

      private

      def clearing_number_length
        checksum_for_clearing? ? 5 : 4
      end

      def bank_data
        number = digits[0, 4].to_i
        _, found_data = CLEARING_NUMBER_MAP.find { |interval, data| interval.include?(number) }
        found_data || {}
      end

      def min_length
        if bank_data
          Array(serial_number_length).first
        else
          0
        end
      end

      def max_length
        if bank_data
          Array(serial_number_length).last +
            (checksum_for_clearing? ? 1 : 0)
        else
          1 / 0.0  # Infinity.
        end
      end

      def serial_number_length
        bank_data.fetch(:serial_number_length, DEFAULT_SERIAL_NUMBER_LENGTH)
      end

      def luhn_for_serial?
        bank_data[:luhn_for_serial]
      end

      def checksum_for_clearing?
        bank_data[:checksum_for_clearing]
      end

      def digits
        number.to_s.gsub(/\D/, "")
      end

      def zerofill?
        !!bank_data[:zerofill]
      end
    end
  end
end
