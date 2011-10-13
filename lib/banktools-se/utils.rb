module BankTools
  module SE
    module Utils

      # Based on http://blog.internautdesign.com/2007/4/18/ruby-luhn-check-aka-mod-10-formula
      def self.valid_luhn?(number)
        digits = number.to_s.scan(/\d/).reverse.map { |x| x.to_i }
        digits = digits.each_with_index.map { |d, i|
          d *= 2 if i.odd?
          d > 9 ? d - 9 : d
        }
        sum = digits.inject(0) { |m, x| m + x }
        sum % 10 == 0
      end

    end
  end
end
