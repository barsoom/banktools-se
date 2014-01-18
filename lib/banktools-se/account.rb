# encoding: utf-8

module BankTools
  module SE
    class Account

      # http://www.bgc.se/upload/Gemensamt/Trycksaker/Manualer/BG910.pdf

      DEFAULT_SERIAL_NUMBER_LENGTH = 7

      CLEARING_NUMBER_MAP = {
        1100..1199 => { :name => "Nordea" },
        1200..1399 => { :name => "Danske Bank" },
        1400..2099 => { :name => "Nordea" },
        2300..2399 => { :name => "Ålandsbanken" },
        2400..2499 => { :name => "Danske Bank" },
        3000..3299 => { :name => "Nordea" },
        3300..3300 => { :name => "Nordea", :serial_number_length => 10, :luhn_for_serial => true },  # Personkonto.
        3301..3399 => { :name => "Nordea" },
        3400..3409 => { :name => "Länsförsäkringar Bank" },
        3410..3781 => { :name => "Nordea" },
        3782..3782 => { :name => "Nordea", :serial_number_length => 10, :luhn_for_serial => true },  # Personkonto.
        3783..4999 => { :name => "Nordea" },
        5000..5999 => { :name => "SEB" },
        6000..6999 => { :name => "Handelsbanken", :serial_number_length => 9 },
        7000..7999 => { :name => "Swedbank" },
        # Can be fewer chars but must be zero-filled, so let's call it 10.
        8000..8999 => { :name => "Swedbank", :serial_number_length => 10, :checksum_for_clearing => true, :zerofill => true },
        9020..9029 => { :name => "Länsförsäkringar Bank" },
        9040..9049 => { :name => "Citibank" },
        9060..9069 => { :name => "Länsförsäkringar Bank" },
        9090..9099 => { :name => "Royal Bank of Scotland" },
        9100..9109 => { :name => "Nordnet Bank" },
        9120..9124 => { :name => "SEB" },
        9130..9149 => { :name => "SEB" },
        9150..9169 => { :name => "Skandiabanken" },
        9170..9179 => { :name => "Ikano Bank" },
        9180..9189 => { :name => "Danske Bank", :serial_number_length => 10 },
        9190..9199 => { :name => "Den Norske Bank" },
        9230..9239 => { :name => "Marginalen Bank" },
        9250..9259 => { :name => "SBAB" },
        9260..9269 => { :name => "Den Norske Bank" },
        9270..9279 => { :name => "ICA Banken" },
        9280..9289 => { :name => "Resurs Bank" },
        9300..9349 => { :name => "Sparbanken Öresund", :serial_number_length => 10, :zerofill => true },
        9400..9449 => { :name => "Forex Bank" },
        9460..9469 => { :name => "GE Money Bank" },
        9470..9479 => { :name => "Fortis Bank" },
        9500..9549 => { :name => "Nordea/Plusgirot", :serial_number_length => 1..10 },
        9550..9569 => { :name => "Avanza Bank" },
        9570..9579 => { :name => "Sparbanken Syd", :serial_number_length => 10, :zerofill => true},
        9960..9969 => { :name => "Nordea/Plusgirot", :serial_number_length => 1..10 },
      }

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
          digits[0,4],
          checksum_for_clearing? ? digits[4,1] : nil
        ].compact.join("-")
      end

      def serial_number
        number = digits.slice(clearing_number_length..-1) || ""
        zerofill? ? "%.#{bank_data[:serial_number_length]}d" % number.to_i(10) : number
      end

      private

      def clearing_number_length
        checksum_for_clearing? ? 5 : 4
      end

      def bank_data
        number = digits[0,4].to_i
        _, found_data = CLEARING_NUMBER_MAP.find do |interval, data|
          interval.include?(number)
        end
        found_data || {}
      end

      def min_length
        if bank_data
          Array(bank_data[:serial_number_length] || DEFAULT_SERIAL_NUMBER_LENGTH).first
        else
          0
        end
      end

      def max_length
        if bank_data
          Array(bank_data[:serial_number_length] || DEFAULT_SERIAL_NUMBER_LENGTH).last +
            (checksum_for_clearing? ? 1 : 0)
        else
          1/0.0  # Infinity.
        end
      end

      def luhn_for_serial?
        bank_data[:luhn_for_serial]
      end

      def checksum_for_clearing?
        bank_data[:checksum_for_clearing]
      end

      def digits
        number.to_s.gsub(/\D/, '')
      end

      def zerofill?
        !!bank_data[:zerofill]
      end

    end
  end
end
