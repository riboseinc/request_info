# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'request_info/version'

Gem::Specification.new do |spec|
  spec.name          = 'request_info'
  spec.version       = RequestInfo::VERSION
  spec.authors       = ['Ribose Inc.']
  spec.email         = ['open.source@ribose.com']

  spec.summary       = 'Detect request IP, timezone and locale information with ease'
  spec.homepage      = 'https://github.com/riboseinc/request_info'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 
  # 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.has_rdoc              = true
  spec.required_ruby_version = ">= 2.2.0"

  spec.add_dependency('rails', '>= 3.1.0')
  spec.add_dependency('i18n')
  spec.add_dependency('maxmind_geoip2')
  spec.add_dependency('tzinfo')

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "pry", "~> 0.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
