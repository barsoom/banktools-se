module BankTools
  module SE
    class Account
      module ClearingNumber
        MAP = {
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
      end
    end
  end
end
