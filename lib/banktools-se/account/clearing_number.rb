# encoding: utf-8

module BankTools
  module SE
    class Account
      module ClearingNumber
        MAP = {
          1100..1199 => { name: "Nordea", serial_number_length: 7 },
          1200..1399 => { name: "Danske Bank", serial_number_length: 7 },
          1400..2099 => { name: "Nordea", serial_number_length: 7 },
          2300..2399 => { name: "Ålandsbanken", serial_number_length: 7 },
          2400..2499 => { name: "Danske Bank", serial_number_length: 7 },
          3000..3299 => { name: "Nordea", serial_number_length: 7 },
          3300..3300 => { name: "Nordea", serial_number_length: 10, luhn_for_serial: true }, # Personkonto.
          3301..3399 => { name: "Nordea", serial_number_length: 7 },
          3400..3409 => { name: "Länsförsäkringar Bank", serial_number_length: 7 },
          3410..3781 => { name: "Nordea", serial_number_length: 7 },
          3782..3782 => { name: "Nordea", serial_number_length: 10, luhn_for_serial: true }, # Personkonto.
          3783..4999 => { name: "Nordea", serial_number_length: 7 },
          5000..5999 => { name: "SEB", serial_number_length: 7 },
          6000..6999 => { name: "Handelsbanken", serial_number_length: 8..9 },
          7000..7999 => { name: "Swedbank", serial_number_length: 7 },
          # Can be fewer chars but must be zero-filled, so let's call it 10.
          8000..8999 => { name: "Swedbank", serial_number_length: 10, checksum_for_clearing: true, zerofill: true },
          9020..9029 => { name: "Länsförsäkringar Bank", serial_number_length: 7 },
          9040..9049 => { name: "Citibank", serial_number_length: 7 },
          9060..9069 => { name: "Länsförsäkringar Bank", serial_number_length: 7 },
          9090..9099 => { name: "Royal Bank of Scotland", serial_number_length: 7 },
          9120..9124 => { name: "SEB", serial_number_length: 7 },
          9130..9149 => { name: "SEB", serial_number_length: 7 },
          9150..9169 => { name: "Skandiabanken", serial_number_length: 7 },
          9170..9179 => { name: "Ikano Bank", serial_number_length: 7 },
          9180..9189 => { name: "Danske Bank", serial_number_length: 10 },
          9190..9199 => { name: "Den Norske Bank", serial_number_length: 7 },
          9230..9239 => { name: "Marginalen Bank", serial_number_length: 7 },
          9250..9259 => { name: "SBAB", serial_number_length: 7 },
          9260..9269 => { name: "Den Norske Bank", serial_number_length: 7 },
          9270..9279 => { name: "ICA Banken", serial_number_length: 7 },
          9300..9349 => { name: "Swedbank (fd. Sparbanken Öresund)", serial_number_length: 10, zerofill: true },
          9470..9479 => { name: "BNP Paribas", serial_number_length: 7 },
          9570..9579 => { name: "Sparbanken Syd", serial_number_length: 10, zerofill: true },
          9660..9669 => { name: "Svea Bank" },
          9670..9679 => { name: "JAK Medlemsbank" },
          9700..9709 => { name: "Ekobanken" }
        }
      end
    end
  end
end
