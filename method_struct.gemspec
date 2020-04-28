# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'method_struct/version'

Gem::Specification.new do |spec|
  spec.name          = "method_struct"
  spec.version       = MethodStruct::VERSION
  spec.authors       = ["Zendesk"]
  spec.email         = ["opensource@zendesk.com"]
  spec.description   = %q{Facilitates extracting methods into separate objects}
  spec.summary       = %q{Facilitates extracting methods into separate objects}
  spec.homepage      = "https://github.com/basecrm/method_struct"
  spec.license       = "Apache-2.0"


  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  if RUBY_PLATFORM =~ /java/
    spec.required_ruby_version = ">= 1.7.27"
  else 
    spec.required_ruby_version = ">= 2.3.8"
  end
  
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rspec", "~> 2.14.1"
end
