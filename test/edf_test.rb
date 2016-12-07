# frozen_string_literal: true

require 'test_helper'
require 'tempfile'

class EdfTest < Minitest::Test
  def setup
    @valid_edf_no_data_records = Edfize::Edf.new('test/support/zero-data-records.edf')
    @valid_edf_with_three_signals = Edfize::Edf.new('test/support/simulated-01.edf')
    @edf_invalid_date = Edfize::Edf.new('test/support/invalid-date.edf')
  end

  def test_edf_version
    assert_equal 0, @valid_edf_no_data_records.send('compute_offset', :version)
    assert_equal 0, @valid_edf_no_data_records.version
  end

  def test_edf_local_patient_identification
    assert_equal 8, @valid_edf_no_data_records.send('compute_offset', :local_patient_identification)
    assert_equal '', @valid_edf_no_data_records.local_patient_identification
  end

  def test_edf_local_recording_identification
    assert_equal 88, @valid_edf_no_data_records.send('compute_offset', :local_recording_identification)
    assert_equal '', @valid_edf_no_data_records.local_recording_identification
  end

  def test_edf_start_date_of_recording
    assert_equal 168, @valid_edf_no_data_records.send('compute_offset', :start_date_of_recording)
    assert_equal '31.01.85', @valid_edf_no_data_records.start_date_of_recording
  end

  def test_edf_start_date
    assert_equal Date.parse('1985-01-31'), @valid_edf_no_data_records.start_date
    assert_nil @edf_invalid_date.start_date
  end

  def test_edf_start_time_of_recording
    assert_equal 176, @valid_edf_no_data_records.send('compute_offset', :start_time_of_recording)
    assert_equal '20.14.57', @valid_edf_no_data_records.start_time_of_recording
  end

  def test_edf_number_of_bytes_in_header
    assert_equal 184, @valid_edf_no_data_records.send('compute_offset', :number_of_bytes_in_header)
    assert_equal 3840, @valid_edf_no_data_records.number_of_bytes_in_header
  end

  def test_edf_reserved
    assert_equal 192, @valid_edf_no_data_records.send('compute_offset', :reserved)
    assert_equal ' '*44, @valid_edf_no_data_records.reserved
  end

  def test_edf_number_of_data_records
    assert_equal 236, @valid_edf_no_data_records.send('compute_offset', :number_of_data_records)
    assert_equal 0, @valid_edf_no_data_records.number_of_data_records
  end

  def test_edf_duration_of_a_data_record
    assert_equal 244, @valid_edf_no_data_records.send('compute_offset', :duration_of_a_data_record)
    assert_equal 1, @valid_edf_no_data_records.duration_of_a_data_record
  end

  def test_edf_number_of_signals
    assert_equal 252, @valid_edf_no_data_records.send('compute_offset', :number_of_signals)
    assert_equal 14, @valid_edf_no_data_records.number_of_signals
  end

  # Signal Header Tests

  def test_edf_signal_labels
    assert_equal 0, @valid_edf_no_data_records.send('compute_signal_offset', :label)
    assert_equal ["SaO2", "H.R.", "EEG(sec)", "ECG", "EMG", "EOG(L)", "EOG(R)", "EEG", "THOR RES", "ABDO RES", "POSITION", "LIGHT", "NEW AIR", "OX stat"], @valid_edf_no_data_records.signals.collect(&:label)
  end

  def test_edf_signal_transducer_types
    assert_equal 16, @valid_edf_no_data_records.send('compute_signal_offset', :transducer_type)
    assert_equal [""]*14, @valid_edf_no_data_records.signals.collect(&:transducer_type)
  end

  def test_edf_signal_physical_dimensions
    assert_equal 96, @valid_edf_no_data_records.send('compute_signal_offset', :physical_dimension)
    assert_equal ["", "", "uV", "mV", "uV", "uV", "uV", "uV", "", "", "", "", "uV", ""], @valid_edf_no_data_records.signals.collect(&:physical_dimension)
  end

  def test_edf_signal_physical_minimums
    assert_equal 104, @valid_edf_no_data_records.send('compute_signal_offset', :physical_minimum)
    assert_equal [0.0, 0.0, -125.0, -1.25, -31.25, -125.0, -125.0, -125.0, 1.0, 1.0, 0.0, 0.0, -125.0, 0.0], @valid_edf_no_data_records.signals.collect(&:physical_minimum)
  end

  def test_edf_signal_physical_maximums
    assert_equal 112, @valid_edf_no_data_records.send('compute_signal_offset', :physical_maximum)
    assert_equal [100.0, 250.0, 125.0, 1.25 , 31.25, 125.0, 125.0, 125.0, -1.0, -1.0, 3.0 , 1.0 , 125.0, 3.0], @valid_edf_no_data_records.signals.collect(&:physical_maximum)
  end

  def test_edf_signal_digital_minimums
    assert_equal 120, @valid_edf_no_data_records.send('compute_signal_offset', :digital_minimum)
    assert_equal [-32768, -32768, -128, -128, -128, -128, -128, -128, -128, -128, 0, 0, -128, 0], @valid_edf_no_data_records.signals.collect(&:digital_minimum)
  end

  def test_edf_signal_digital_maximums
    assert_equal 128, @valid_edf_no_data_records.send('compute_signal_offset', :digital_maximum)
    assert_equal [32767, 32767, 127, 127, 127, 127, 127, 127, 127, 127, 3, 1, 127, 3], @valid_edf_no_data_records.signals.collect(&:digital_maximum)
  end

  def test_edf_signal_prefilterings
    assert_equal 136, @valid_edf_no_data_records.send('compute_signal_offset', :prefiltering)
    assert_equal [""]*14, @valid_edf_no_data_records.signals.collect(&:prefiltering)
  end

  def test_edf_signal_samples_per_data_records
    assert_equal 216, @valid_edf_no_data_records.send('compute_signal_offset', :samples_per_data_record)
    assert_equal [1, 1, 125, 125, 125, 50, 50, 125, 10, 10, 1, 1, 10, 1], @valid_edf_no_data_records.signals.collect(&:samples_per_data_record)
  end

  def test_edf_signal_reserved_areas
    assert_equal 224, @valid_edf_no_data_records.send('compute_signal_offset', :reserved_area)
    assert_equal [" "*32]*14, @valid_edf_no_data_records.signals.collect(&:reserved_area)
  end

  def test_loads_single_epoch
    # Load the first epoch (0 index), with the epoch size being 1 second
    @valid_edf_with_three_signals.load_epoch(0,1)
    @signal_one   = @valid_edf_with_three_signals.signals[0]
    @signal_two   = @valid_edf_with_three_signals.signals[1]
    @signal_three = @valid_edf_with_three_signals.signals[2]
    assert_equal [0,1], @signal_one.digital_values
    assert_equal [50.000762951094835, 50.002288853284504], @signal_one.physical_values
    assert_equal [0,1], @signal_two.digital_values
    assert_equal [125.00190737773708, 125.00572213321126], @signal_two.physical_values
    assert_equal [0,1,2,3], @signal_three.digital_values
    assert_equal [0.49019607843136725, 1.470588235294116, 2.4509803921568647, 3.4313725490196134], @signal_three.physical_values
  end

  def test_loads_last_epoch
    # Load the last epoch (0 index), with the epoch size being 1 second
    @valid_edf_with_three_signals.load_epoch(9,1)
    @signal_one   = @valid_edf_with_three_signals.signals[0]
    @signal_two   = @valid_edf_with_three_signals.signals[1]
    @signal_three = @valid_edf_with_three_signals.signals[2]
    assert_equal [9,nil], @signal_one.digital_values
    assert_equal [50.01449607080186,nil], @signal_one.physical_values
    assert_equal [9,nil], @signal_two.digital_values
    assert_equal [125.03624017700466,nil], @signal_two.physical_values
    assert_equal [18,19,nil,nil], @signal_three.digital_values
    assert_equal [18.137254901960773, 19.117647058823536,nil,nil], @signal_three.physical_values
  end

  def test_loads_last_epoch_of_two_seconds
    # Load the fourth epoch (0 index), with the epoch size being 2 seconds
    @valid_edf_with_three_signals.load_epoch(3,2)
    @signal_one   = @valid_edf_with_three_signals.signals[0]
    @signal_two   = @valid_edf_with_three_signals.signals[1]
    @signal_three = @valid_edf_with_three_signals.signals[2]
    assert_equal [6,7,8], @signal_one.digital_values
    assert_equal [50.00991836423285, 50.01144426642252, 50.01297016861219], @signal_one.physical_values
    assert_equal [6,7,8], @signal_two.digital_values
    assert_equal [125.02479591058213, 125.02861066605631, 125.03242542153048], @signal_two.physical_values
    assert_equal [12,13,14,15,16,17], @signal_three.digital_values
    assert_equal [12.25490196078431, 13.235294117647072, 14.215686274509807, 15.196078431372541, 16.176470588235304, 17.15686274509804], @signal_three.physical_values
  end

  def test_should_rewrite_start_date_of_recording
    file = Tempfile.new('invalid-date-copy.edf')
    FileUtils.cp('test/support/invalid-date.edf', file.path)
    edf = Edfize::Edf.new(file.path)
    assert_equal '00.00.00', edf.start_date_of_recording
    edf.update(start_date_of_recording: '01.01.85')
    edf_new = Edfize::Edf.new(file.path) # Load new EDF to check that change is written to disk.
    assert_equal '01.01.85', edf_new.start_date_of_recording
  ensure
    file.close
    file.unlink # Deletes temporary file.
  end

  def test_should_rewrite_start_time_of_recording
    file = Tempfile.new('invalid-date-copy.edf')
    FileUtils.cp('test/support/invalid-date.edf', file.path)
    edf = Edfize::Edf.new(file.path)
    assert_equal '20.14.57', edf.start_time_of_recording
    edf.update(start_time_of_recording: '12.34.56')
    edf_new = Edfize::Edf.new(file.path) # Load new EDF to check that change is written to disk.
    assert_equal '12.34.56', edf_new.start_time_of_recording
  ensure
    file.close
    file.unlink # Deletes temporary file.
  end
end
