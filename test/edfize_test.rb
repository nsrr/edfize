# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

class EdfizeTest < Minitest::Test
  def setup
    FileUtils.cd('test/support')
    @original_stdout = $stdout
    $stdout = StringIO.new
  end

  def teardown
    $stdout = @original_stdout
    @original_stdout = nil
    FileUtils.cd('../..')
  end

  def test_edfize_application
    assert_kind_of Module, Edfize
  end

  def test_edfize_version
    assert_kind_of String, Edfize::VERSION::STRING
  end

  def test_version_command
    assert_nil Edfize.launch(['v'])
  end

  def test_help_command
    assert_nil Edfize.launch(['h'])
  end

  def test_test_command
    assert_nil Edfize.launch(['t'])
  end

  def test_run_command
    assert_equal %w(invalid-date.edf simulated-01.edf zero-data-records.edf), Edfize.launch(['r']).sort
  end
end
