# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'round_cloud/version'

Gem::Specification.new do |spec|
  spec.name          = 'round_cloud'
  spec.version       = RoundCloud::VERSION
  spec.authors       = ['Aliaksandr Rahalevich']
  spec.email         = ['saksmlz@gmail.com']

  spec.summary       = %q{Provides executable for building and packaging gem}
  spec.description   = %q{Allows to build gem on circle ci and publish to packagecloud.io}
  spec.homepage      = 'https://github.com/saks/round_cloud'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'thor'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry-doc'
end
