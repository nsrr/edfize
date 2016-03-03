# frozen_string_literal: true

require 'simplecov'

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require File.expand_path('../../lib/edfize', __FILE__)
