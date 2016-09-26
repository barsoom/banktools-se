# Swedish bank tools

[![Build Status](https://secure.travis-ci.org/barsoom/banktools-se.png)](http://travis-ci.org/barsoom/banktools-se)

Ruby gem to validate, normalize/prettify and to some extent interpret

  * Swedish bank account numbers
  * Swedish plusgiro numbers
  * Swedish bankgiro numbers

It can also generate and unpack payment OCR numbers (reference codes) with a check digit, optional length digit and optional padding digits.

This gem does what it can to weed out invalid numbers but errs on the side of allowing too much, in the absence of good specifications, so be advised that a "valid" number might still be incorrect.

Inspired by [iulianu/iban-tools](https://github.com/iulianu/iban-tools). Please consider contributing gems for your country.


## Usage

    # Bankgiro

    valid_account = BankTools::SE::Bankgiro.new(" 5402968 1 ")
    valid_account.valid?  # => true
    valid_account.errors  # => []
    valid_account.normalize  # => "5402-9681"

    bad_account = BankTools::SE::Bankgiro.new(" 1X ")
    bad_account.valid?  # => false
    bad_account.errors  # => [ :too_short, :invalid_characters, :bad_checksum ]
    bad_account.normalize  # => " 1 "

    # 90-konto
    fundraising_account = BankTools::SE::Bankgiro.new("902-0033")
    fundraising_account.fundraising?  # => true

    # OCR
    BankTools::SE::OCR.from_number("123")  # => "1230"
    BankTools::SE::OCR.from_number("123", length_digit: true)  # => "12351"
    BankTools::SE::OCR.from_number("123", length_digit: true, pad: "0")  # => "123067"
    BankTools::SE::OCR.to_number("1230")  # => "123"
    BankTools::SE::OCR.to_number("123067", length_digit: true, pad: "0")  # => "123"

    # Plusgiro

    valid_account = BankTools::SE::Plusgiro.new("2865434")
    valid_account.valid?  # => true
    valid_account.errors  # => []
    valid_account.normalize  # => "28 65 53-4"

    bad_account = BankTools::SE::Plusgiro.new(" 1X ")
    bad_account.valid?  # => false
    bad_account.errors  # => [ :too_short, :invalid_characters, :bad_checksum ]
    bad_account.normalize  # => " 1 "

    # 90-konto
    fundraising_account = BankTools::SE::Plusgiro.new("90 20 03-3")
    fundraising_account.fundraising?  # => true


    # Bank account

    valid_account = BankTools::SE::Account.new("11000000000")
    valid_account.valid?  # => true
    valid_account.errors  # => []
    valid_account.normalize  # => "1100-0000000"
    valid_account.bank  # => "Nordea"
    valid_account.clearing_number  # => "1100"
    valid_account.serial_number  # => "0000000"

    bad_account = BankTools::SE::Account.new(" 0000-0000000X ")
    bad_account.valid?  # => false
    bad_account.errors  # => [ :invalid_characters, :unknown_clearing_number ]
    bad_account.bank  # => nil
    bad_account.normalize  # => " 0000-0000000X "


    # Error codes

    BankTools::SE::Errors::TOO_SHORT                # => :too_short
    BankTools::SE::Errors::TOO_LONG                 # => :too_long
    BankTools::SE::Errors::INVALID_CHARACTERS       # => :invalid_characters
    BankTools::SE::Errors::BAD_CHECKSUM             # => :bad_checksum
    BankTools::SE::Errors::UNKNOWN_CLEARING_NUMBER  # => :unknown_clearing_number


## Installation

Add this line to your application's Gemfile:

    gem 'banktools-se'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install banktools-se


## TODO

Possible improvements to make:

  * Luhn validation based on [BGC docs](http://www.bgc.se/upload/Gemensamt/Trycksaker/Manualer/BG910.pdf).


## Also see

* [BankTools::DE (German)](https://github.com/barsoom/banktools-de)
* [iban-tools](https://github.com/iulianu/iban-tools)


## Credits and license

By [Henrik Nyh](http://henrik.nyh.se/) for [Barsoom](http://barsoom.se) under the MIT license:

>  Copyright (c) 2011 Barsoom AB
>
>  Permission is hereby granted, free of charge, to any person obtaining a copy
>  of this software and associated documentation files (the "Software"), to deal
>  in the Software without restriction, including without limitation the rights
>  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
>  copies of the Software, and to permit persons to whom the Software is
>  furnished to do so, subject to the following conditions:
>
>  The above copyright notice and this permission notice shall be included in
>  all copies or substantial portions of the Software.
>
>  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
>  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
>  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
>  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
>  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
>  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
>  THE SOFTWARE.
