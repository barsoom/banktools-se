# encoding: utf-8

module BankTools
  module SE
    class Account

      # http://sv.wikipedia.org/wiki/Lista_%C3%B6ver_clearingnummer_till_svenska_banker
      # Max lengths from
      #   http://www.danskebank.se/sv-se/eBanking-content/text-pages/Pages/Bankliste2.aspx
      # Min lengths are educated guesses based on the above and
      #   http://sv.wikipedia.org/wiki/Bankkonto
      # When it's uncertain, let's error on the side of allowing too much.
      # 1..99 means we have no idea.

      DEFAULT_SERIAL_NUMBER_LENGTH = 7

      CLEARING_NUMBER_MAP = {
        1100..1199 => { :name => "Nordea" },
        1200..1399 => { :name => "Danske Bank" },
        1400..2099 => { :name => "Nordea" },
        2300..2309 => { :name => "JP Nordiska", :serial_number_length => 1..99 },
        2310..2310 => { :name => "Ålandsbanken" },
        2311..2399 => { :name => "JP Nordiska", :serial_number_length => 1..99 },
        2950..2950 => { :name => "Sambox", :serial_number_length => 1..99 },
        3000..3299 => { :name => "Nordea" },
        3300..3300 => { :name => "Nordea", :serial_number_length => 10, :luhn_for_serial => true },  # Personkonto.
        3301..3399 => { :name => "Nordea" },
        3400..3409 => { :name => "Länsförsäkringar Bank" },
        3410..3781 => { :name => "Nordea" },
        3782..3782 => { :name => "Nordea", :serial_number_length => 10, :luhn_for_serial => true },  # Personkonto.
        3783..4999 => { :name => "Nordea" },
        5000..5999 => { :name => "SEB" },
        6000..6999 => { :name => "Handelsbanken", :serial_number_length => 9 },
        7000..7120 => { :name => "Swedbank" },
        7121..7122 => { :name => "Sparbanken i Enköping", :serial_number_length => 7..10 },  # 7? 10? Who knows.
        7123..7999 => { :name => "Swedbank" },
        8000..8999 => { :name => "Swedbank och fristående Sparbanker", :serial_number_length => 10, :checksum_for_clearing => true },
        9020..9029 => { :name => "Länsförsäkringar Bank" },
        9040..9049 => { :name => "Citibank" },
        9050..9059 => { :name => "HSB Bank", :serial_number_length => 1..99 },
        9060..9069 => { :name => "Länsförsäkringar Bank" },
        9080..9080 => { :name => "Calyon Bank", :serial_number_length => 1..99 },
        9090..9099 => { :name => "ABN AMRO", :serial_number_length => 1..99 },
        9100..9100 => { :name => "Nordnet Bank" },
        9120..9124 => { :name => "SEB" },
        9130..9149 => { :name => "SEB" },
        9150..9169 => { :name => "Skandiabanken" },
        9170..9179 => { :name => "Ikano Bank" },
        9180..9189 => { :name => "Danske Bank" },
        9190..9199 => { :name => "Den Norske Bank" },
        9200..9209 => { :name => "Stadshypotek Bank", :serial_number_length => 1..99 },
        9230..9230 => { :name => "Bank2" },
        9231..9239 => { :name => "SalusAnsvar Bank", :serial_number_length => 1..99 },
        9260..9269 => { :name => "Gjensidige NOR Sparebank", :serial_number_length => 1..99 },
        9270..9279 => { :name => "ICA Banken" },
        9280..9289 => { :name => "Resurs Bank" },
        9290..9299 => { :name => "Coop Bank", :serial_number_length => 1..99 },
        9300..9349 => { :name => "Sparbanken Öresund", :serial_number_length => 10 },
        9400..9400 => { :name => "Forex Bank" },
        9460..9460 => { :name => "GE Money Bank" },
        9469..9469 => { :name => "GE Money Bank" },
        9500..9547 => { :name => "Plusgirot Bank", :serial_number_length => 10 },
        9548..9548 => { :name => "Ekobanken", :serial_number_length => 1..99 },
        9549..9549 => { :name => "JAK Medlemsbank", :serial_number_length => 1..99 },
        9550..9550 => { :name => "Avanza Bank" },
        9960..9969 => { :name => "Plusgirot Bank", :serial_number_length => 10 },
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

        errors << :too_short if serial_number.length < min_length
        errors << :too_long if serial_number.length > max_length
        errors << :invalid_characters if number.to_s.match(/[^0-9 -]/)

        if luhn_for_serial?
          errors << :bad_checksum unless BankTools::SE::Utils.valid_luhn?(serial_number)
        end

        errors << :unknown_clearing_number unless bank

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
        digits[0,4]
      end

      def serial_number
        value = digits[4..-1] || ""
        if checksum_for_clearing? && value.length == max_length
          value[1..-1]
        else
          value
        end
      end

      private

      def bank_data
        number = clearing_number.to_i
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

    end
  end
end
