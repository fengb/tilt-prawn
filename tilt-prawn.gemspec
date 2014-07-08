$:.push File.expand_path("../lib", __FILE__)
require 'tilt/prawn/version'

Gem::Specification.new do |gem|
  gem.name              = 'tilt-prawn'
  gem.version           = Tilt::Prawn::VERSION
  gem.authors           = 'Benjamin Feng'
  gem.email             = 'contact@fengb.info'
  gem.summary           = 'tilt-prawn integrates prawn with tilt'
  gem.description       = 'tilt-prawn integrates prawn with tilt'
  gem.license           = 'MIT'

  gem.files = Dir["lib/**/*"] + %w[LICENSE]
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'tilt', '>= 1.4'
  gem.add_runtime_dependency 'prawn', '>= 1.0'

  gem.add_development_dependency 'rspec', '>= 3.0.0'
end
