# Compiling the Gem
# gem build edfize.gemspec
# gem install ./edfize-x.x.x.gem --no-ri --no-rdoc --local
#
# gem push edfize-x.x.x.gem
# gem list -r edfize
# gem install edfize

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'edfize/version'

Gem::Specification.new do |spec|
  spec.name          = "edfize"
  spec.version       = Edfize::VERSION::STRING
  spec.authors       = ["Remo Mueller"]
  spec.email         = ["remosm@gmail.com"]
  spec.summary       = %q{Load, validate, and parse European Data Format files. Used for batch testing EDFs for errors.}
  spec.description   = %q{Load, validate, and parse European Data Format files. Used for batch testing EDFs for errors. Run `edfize` on command line to view full list of options.}
  spec.homepage      = "https://github.com/sleepepi/edfize"
  spec.license       = "CC BY-NC-SA 3.0"

  spec.files         = Dir['{bin,lib}/**/*'] + ['CHANGELOG.md', 'LICENSE.txt', 'Rakefile', 'README.md', 'edfize.gemspec']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "colorize", "~> 0.7.2"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
