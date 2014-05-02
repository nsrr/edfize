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

end
