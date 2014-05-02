require 'test_helper'

class EdfTest < Test::Unit::TestCase

  def setup
    @valid_edf_no_data_records = Edfize::Edf.new('test/support/zero-data-records.edf')
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
    assert_equal '00.00.00', @valid_edf_no_data_records.start_date_of_recording
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

end
