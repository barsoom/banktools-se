# Changelog

## 3.3.0

- Add Lunar Bank clearing number range. [#14](https://github.com/barsoom/banktools-se/pull/14). Thanks, @andyglim!

## 3.2.0

- Add Account#normalize keyword arguments `digits_only`, `clearing_checksum`. [#11](https://github.com/barsoom/banktools-se/pull/11)

## 3.1.1

- Require MFA for privileged Rubygems actions.

## 3.1.0

- Add more banks to the range in `BankTools::SE::Account::ClearingNumber`. See [#7]. Thanks, Milen Dimitrov!

## 3.0.1

- Fix deprecation error: "NOTE: Gem::Specification#rubyforge_project= is deprecated with no replacement. It will be removed on or after 2019-12-01."

## 3.0.0

- Change `BankTools::SE::OCR.find_all_in_string` default `max_length` from 19 to 18 to avoid out of range errors with Active Record.

## 2.6.3 and earlier

- Please see commit history.

[#7]: https://github.com/barsoom/banktools-se/pull/7
