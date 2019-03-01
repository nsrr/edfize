# frozen_string_literal: true

# Compiling the Gem
# gem build edfize.gemspec
# gem install ./edfize-x.x.x.gem --no-document --local
#
# gem push edfize-x.x.x.gem
# gem list -r edfize
# gem install edfize

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "edfize/version"

Gem::Specification.new do |spec|
  spec.name          = "edfize"
  spec.version       = Edfize::VERSION::STRING
  spec.authors       = ["Remo Mueller"]
  spec.email         = ["remosm@gmail.com"]
  spec.summary       = "Load, validate, and parse European Data Format files. Used for batch testing EDFs for errors."
  spec.description   = "Load, validate, and parse European Data Format files. Used for batch testing EDFs for errors. \
Run `edfize` on command line to view full list of options."
  spec.homepage      = "https://github.com/sleepepi/edfize"
  spec.license       = "MIT"

  spec.files         = Dir["{bin,lib}/**/*"] + %w(CHANGELOG.md LICENSE Rakefile README.md edfize.gemspec)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler", ">= 1.3.0"
  spec.add_dependency "rake"
end
