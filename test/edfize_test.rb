require 'test_helper'

class EdfizeTest < Test::Unit::TestCase

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

end
