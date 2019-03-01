# Edfize

[![Build Status](https://travis-ci.org/sleepepi/edfize.svg?branch=master)](https://travis-ci.org/sleepepi/edfize)
[![Dependency Status](https://gemnasium.com/sleepepi/edfize.svg)](https://gemnasium.com/sleepepi/edfize)
[![Code Climate](https://codeclimate.com/github/sleepepi/edfize/badges/gpa.svg)](https://codeclimate.com/github/sleepepi/edfize)

Ruby gem used to load, validate, and parse European Data Format files. Used for
batch testing EDFs for errors. Ruby 2.6+ compatible.

## Installation

Use `gem install edfize` to update Edfize to the latest stable

Use `gem install edfize --pre` to update Edfize to the latest prerelease

## Usage

### Validate EDFs

Use `edfize test` to test that EDFs stored in the current directory have a valid
format.

    cd <edf-directory>
    edfize test

A list of validations performed is:

- **Expected Length Check**: Compares the calculated size of the file based on
  signal sizes defined in the header with the actual file size. A failure may
  indicate corruption in the header (if the expected is less than the actual
  file size), or a partial/truncated file (if the expected is more than the
  actual file size).
- **Reserved Area Checks**: Check that reserved areas are blank. Non-blank
  reserved areas can indicate a sign of header or EDF file corruption.

Flags that can be added to the `test` command include:

- `--failing`: Only display EDFs with failing tests
- `--quiet`: Suppress detailed failure descriptions that show the expected
  versus the actual result of the test

### Print Signal Header information

Use `edfize run` to print out signal header information for each EDF in the
current directory.

    cd <edf-directory>
    edfize run

### View A List of All Available Commands for Edfize

Use `edfize help` to list available commands and descriptions for Edfize.

    edfize help

### View Current Version of Edfize

Use `edfize version` to check the version of Edfize.

    edfize version

### Example of how to rewrite the start date of recording for a folder of EDFs

This will update all EDFs in the current directory and subdirectories with a
start date of 1st Jan 1985.

`rewrite_signal_date.rb`
```ruby
# gem install edfize --no-document
# ruby rewrite_signal_date.rb

require 'rubygems'
require 'edfize'

CLIPPING_DATE = '01.01.85'

Edfize.edfs do |edf|
  edf.update(start_date_of_recording: CLIPPING_DATE)
end
```

### Example of how to Load and Analyze EDFs in a Ruby Script

The following Ruby file demonstrates how to make use of the Edfize gem to load
EDF signals into arrays for analysis.

`tutorial_01_load_edf_and_signals.rb`
```ruby
# Tutorial 01 - Load EDF and Signals
#
#   gem install edfize --no-document
#
#   ruby tutorial_01_load_edf_and_signals.rb
#
# The EDF exists at:
#
#    https://sleepdata.org/datasets/shhs/files/edfs/shhs1?f=shhs1-200001.edf
#

require 'rubygems'
require 'edfize'

# Loads the file and reads the EDF Header
edf = Edfize::Edf.new('shhs1-200001.edf')

# Loads the data section of the EDF into Signal objects
edf.load_signals

# Print out information on the signals
puts "EDF #{edf.filename} contains the following #{edf.signals.count} signal#{'s' unless edf.signals.count == 1}:\n\n"

edf.signals.each do |signal|
  puts "Signal"
  puts "  Label                    : #{signal.label}"
  puts "  Samples Per Data Record  : #{signal.samples_per_data_record}"
  puts "  First 10 Physical Values : #{(signal.physical_values[0..10] + ['...']).inspect}\n\n"
end
```

When run, the code above will output the following:

```console
EDF shhs1-200001.edf contains the following 14 signals:

Signal
  Label                    : SaO2
  Samples Per Data Record  : 1
  First 10 Physical Values : [95.31242847333486, 95.31242847333486, 95.31242847333486, 95.31242847333486, 95.31242847333486, 95.31242847333486, 95.31242847333486, 95.31242847333486, 94.14053559166858, 94.14053559166858, 94.14053559166858, "..."]

Signal
  Label                    : H.R.
  Samples Per Data Record  : 1
  First 10 Physical Values : [77.34416723887999, 77.34416723887999, 77.34416723887999, 76.56595712214848, 76.56595712214848, 76.56595712214848, 75.00190737773708, 75.00190737773708, 75.00190737773708, 75.00190737773708, 75.00190737773708, "..."]

Signal
  Label                    : EEG(sec)
  Samples Per Data Record  : 125
  First 10 Physical Values : [-4.411764705882348, 5.392156862745111, 2.4509803921568647, 0.49019607843136725, -0.49019607843136725, -10.294117647058826, 3.4313725490196134, 12.25490196078431, -1.470588235294116, -2.4509803921568647, -8.333333333333329, "..."]

Signal
  Label                    : ECG
  Samples Per Data Record  : 125
  First 10 Physical Values : [0.03431372549019618, 0.03431372549019618, 0.03431372549019618, 0.03431372549019618, 0.044117647058823595, 0.044117647058823595, 0.044117647058823595, 0.044117647058823595, 0.044117647058823595, 0.03431372549019618, 0.03431372549019618, "..."]

Signal
  Label                    : EMG
  Samples Per Data Record  : 125
  First 10 Physical Values : [12.622549019607845, 3.7990196078431353, -3.5539215686274517, -2.5735294117647065, 8.455882352941174, 1.5931372549019613, 9.436274509803923, -8.700980392156861, -2.5735294117647065, 13.112745098039213, -12.867647058823529, "..."]

Signal
  Label                    : EOG(L)
  Samples Per Data Record  : 50
  First 10 Physical Values : [28.921568627450966, 17.15686274509804, 25.0, 19.117647058823536, -5.392156862745097, -9.313725490196077, -0.49019607843136725, -1.470588235294116, 1.470588235294116, -1.470588235294116, 0.49019607843136725, "..."]

Signal
  Label                    : EOG(R)
  Samples Per Data Record  : 50
  First 10 Physical Values : [12.25490196078431, 1.470588235294116, 10.294117647058812, 5.392156862745111, 17.15686274509804, 18.137254901960773, 25.980392156862735, 32.84313725490196, 25.0, 26.960784313725497, 22.058823529411768, "..."]

Signal
  Label                    : EEG
  Samples Per Data Record  : 125
  First 10 Physical Values : [-2.4509803921568647, 1.470588235294116, -9.313725490196077, -6.372549019607845, -0.49019607843136725, -10.294117647058826, -12.25490196078431, -12.25490196078431, -7.352941176470594, 1.470588235294116, 6.372549019607845, "..."]

Signal
  Label                    : THOR RES
  Samples Per Data Record  : 10
  First 10 Physical Values : [0.207843137254902, 0.207843137254902, 0.15294117647058825, 0.0980392156862745, 0.03529411764705881, -0.0117647058823529, -0.050980392156862786, -0.08235294117647052, -0.10588235294117654, -0.1215686274509804, -0.13725490196078427, "..."]

Signal
  Label                    : ABDO RES
  Samples Per Data Record  : 10
  First 10 Physical Values : [0.30980392156862746, 0.24705882352941178, 0.16078431372549018, 0.06666666666666665, -0.0039215686274509665, -0.08235294117647052, -0.1607843137254903, -0.2078431372549019, -0.2313725490196079, -0.2549019607843137, -0.2705882352941176, "..."]

Signal
  Label                    : POSITION
  Samples Per Data Record  : 1
  First 10 Physical Values : [2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, "..."]

Signal
  Label                    : LIGHT
  Samples Per Data Record  : 1
  First 10 Physical Values : [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, "..."]

Signal
  Label                    : NEW AIR
  Samples Per Data Record  : 10
  First 10 Physical Values : [6.372549019607845, 6.372549019607845, 5.392156862745111, 3.4313725490196134, 7.35294117647058, 6.372549019607845, 8.333333333333343, 9.313725490196077, 6.372549019607845, 6.372549019607845, 7.35294117647058, "..."]

Signal
  Label                    : OX stat
  Samples Per Data Record  : 1
  First 10 Physical Values : [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, "..."]
```

## Contributing

1. Fork it ( https://github.com/sleepepi/edfize/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
