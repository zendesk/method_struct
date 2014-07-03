# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'method_struct/version'

Gem::Specification.new do |spec|
  spec.name          = "method_struct"
  spec.version       = MethodStruct::VERSION
  spec.authors       = ["Paweł Obrok"]
  spec.email         = ["pawel.obrok@gmail.com"]
  spec.description   = %q{Facilitates extracting methods into separate objects}
  spec.summary       = %q{Facilitates extracting methods into separate objects}
  spec.homepage      = "https://github.com/basecrm/method_struct"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.1"
end
