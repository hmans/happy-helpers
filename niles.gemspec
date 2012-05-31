# -*- encoding: utf-8 -*-
require File.expand_path('../lib/happy-helpers/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Hendrik Mans"]
  gem.email         = ["hendrik@mans.de"]
  gem.description   = %q{View helpers for your custom Rack app or framework.}
  gem.summary       = %q{View helpers for your custom Rack app or framework.}
  gem.homepage      = "https://github.com/hmans/happy-helpers"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "happy-helpers"
  gem.require_paths = ["lib"]
  gem.version       = HappyHelpers::VERSION

  gem.add_dependency 'tilt', '~> 1.3'
end
