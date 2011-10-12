# Swedish bank tools

Ruby gem to validate, normalize/prettify and to some extent interpret

  * Swedish bank account numbers
  * Swedish plusgiro numbers
  * Swedish bankgiro numbers

Inspired by [iulianu/iban-tools](https://github.com/iulianu/iban-tools). Please consider contributing gems for your country.

## Installation

With Bundler for e.g. Ruby on Rails, add this to your `Gemfile`:

    gem 'banktools-se', :git => 'git://github.com/barsoom/banktools-se.git'

and run

    bundle

to install it.

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

## TODO

This library is in development. The below is yet to be done.

    account = BankTools::SE::BankAccount.new("1234567890")
    account.valid?  # => true, if it had been valid…
    account.errors  # => [ :bad_checksum, :invalid_characters, :too_short, :too_long ], probably not all of these at once…
    account.bank  # => "Swedbank", if it had been that…
    account.normalize  # => "1234-567890", or something

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

