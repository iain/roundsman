# -*- encoding: utf-8 -*-
require File.expand_path('../lib/roundsman/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["iain"]
  gem.email         = ["iain@iain.nl"]
  gem.description   = %q{Combine the awesome powers of Capistrano and Chef. The only thing you need is SSH access.}
  gem.summary       = %q{Various Capistrano tasks for bootstrapping servers with Chef}
  gem.homepage      = "https://github.com/iain/roundsman"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "roundsman"
  gem.require_paths = ["lib"]
  gem.version       = Roundsman::VERSION

  gem.add_runtime_dependency "capistrano", "~> 2.12"
  gem.add_development_dependency "vagrant", "~> 1.0"
end
