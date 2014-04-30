# Edfize

[![Build Status](https://travis-ci.org/sleepepi/edfize.svg?branch=master)](https://travis-ci.org/sleepepi/edfize)
[![Dependency Status](https://gemnasium.com/sleepepi/edfize.svg)](https://gemnasium.com/sleepepi/edfize)
[![Code Climate](https://codeclimate.com/github/sleepepi/edfize.png)](https://codeclimate.com/github/sleepepi/edfize)

Ruby gem used to load, validate, and parse European Data Format files. Used for batch testing EDFs for errors. Ruby 2.0+ compatible.

## Installation

Add this line to your application's Gemfile:

    gem 'edfize'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install edfize

## Usage

### Validate EDFs

Use `edfize check` to check that EDFs stored in the current directory have a valid format.

    cd <edf-directory>
    edfize check

A list of validations performed is:

- **Expected Length Check**: Compares the calculated size of the file based on signal sizes defined in the header with the actual file size. A failure may indicate corruption in the header (if the expected is less than the actual file size), or a partial/truncated file (if the expected is more than the actual file size).
- **Reserved Area Checks**: Check that reserved areas are blank. Non-blank reserved areas can indicate a sign of header or EDF file corruption.

### Print Signal Header information

Use `edfize run` to print out signal header information for each EDF in the current directory.

    cd <edf-directory>
    edfize run

### View A List of All Available Commands for Edfize

Use `edfize help` to list available commands and descriptions for Edfize.

    edfize help

### View Current Version of Edfize

Use `edfize version` to check the version of Edfize.

    edfize version

### Upgrade Edfize

Use `gem install edfize` to update Edfize to the latest stable

Use `gem install edfize --pre` to update Edfize to the latest prerelease

## Contributing

1. Fork it ( https://github.com/sleepepi/edfize/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
