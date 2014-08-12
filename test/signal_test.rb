require 'test_helper'

class SignalTest < Minitest::Test

  def setup
    @valid_edf_with_three_signals = Edfize::Edf.new('test/support/simulated-01.edf')
    @valid_edf_with_three_signals.load_signals

    @signal_one   = @valid_edf_with_three_signals.signals[0]
    @signal_two   = @valid_edf_with_three_signals.signals[1]
    @signal_three = @valid_edf_with_three_signals.signals[2]
  end

  def test_signal_count
    assert_equal 3, @valid_edf_with_three_signals.signals.count
  end

  def test_signal_one_header
    assert_equal "SaO2", @signal_one.label
    assert_equal "", @signal_one.transducer_type
    assert_equal "", @signal_one.physical_dimension
    assert_equal 0.0, @signal_one.physical_minimum
    assert_equal 100.0, @signal_one.physical_maximum
    assert_equal -32768, @signal_one.digital_minimum
    assert_equal 32767, @signal_one.digital_maximum
    assert_equal "", @signal_one.prefiltering
    assert_equal 1, @signal_one.samples_per_data_record
    assert_equal " "*32, @signal_one.reserved_area
  end

  def test_signal_two_header
    assert_equal "H.R.", @signal_two.label
    assert_equal "", @signal_two.transducer_type
    assert_equal "", @signal_two.physical_dimension
    assert_equal 0.0, @signal_two.physical_minimum
    assert_equal 250.0, @signal_two.physical_maximum
    assert_equal -32768, @signal_two.digital_minimum
    assert_equal 32767, @signal_two.digital_maximum
    assert_equal "", @signal_two.prefiltering
    assert_equal 1, @signal_two.samples_per_data_record
    assert_equal " "*32, @signal_two.reserved_area
  end

  def test_signal_three_header
    assert_equal "EEG(sec)", @signal_three.label
    assert_equal "", @signal_three.transducer_type
    assert_equal "uV", @signal_three.physical_dimension
    assert_equal -125.0, @signal_three.physical_minimum
    assert_equal 125.0, @signal_three.physical_maximum
    assert_equal -128, @signal_three.digital_minimum
    assert_equal 127, @signal_three.digital_maximum
    assert_equal "", @signal_three.prefiltering
    assert_equal 2, @signal_three.samples_per_data_record
    assert_equal " "*32, @signal_three.reserved_area
  end

  def test_signal_one_digital_values
    assert_equal (0..9).to_a, @signal_one.digital_values
  end

  def test_signal_two_digital_values
    assert_equal (0..9).to_a, @signal_two.digital_values
  end

  def test_signal_three_digital_values
    assert_equal (0..19).to_a, @signal_three.digital_values
  end

  def test_signal_one_physical_values
    assert_equal [50.000762951094835, 50.002288853284504, 50.003814755474174, 50.005340657663844, 50.00686655985351, 50.00839246204318, 50.00991836423285, 50.01144426642252, 50.01297016861219, 50.01449607080186], @signal_one.physical_values
  end

  def test_signal_two_physical_values
    assert_equal [125.00190737773708, 125.00572213321126, 125.00953688868543, 125.01335164415961, 125.01716639963378, 125.02098115510796, 125.02479591058213, 125.02861066605631, 125.03242542153048, 125.03624017700466], @signal_two.physical_values
  end

  def test_signal_three_physical_values
    assert_equal [0.49019607843136725, 1.470588235294116, 2.4509803921568647, 3.4313725490196134, 4.411764705882348, 5.392156862745111, 6.372549019607845, 7.35294117647058, 8.333333333333343, 9.313725490196077, 10.294117647058812, 11.274509803921575, 12.25490196078431, 13.235294117647072, 14.215686274509807, 15.196078431372541, 16.176470588235304, 17.15686274509804, 18.137254901960773, 19.117647058823536], @signal_three.physical_values
  end

end
