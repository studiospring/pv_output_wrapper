# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pv_output_wrapper/version'

Gem::Specification.new do |spec|
  spec.name          = "pv_output_wrapper"
  spec.version       = PvOutputWrapper::VERSION
  spec.authors       = ["Sean Loughman"]
  spec.email         = ["lettersforsean@yahoo.co.jp"]
  spec.summary       = 'A wrapper around the [www.pvoutput.org api.](http://www.pvoutput.org/help.html#api)'
  spec.description   = 'This gem wraps only the parts of the [pvoutput.org api](http://www.pvoutput.org/help.html#api) which are used by Solario.'
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "addressable", "~> 2.3"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "guard", "~> 2.13"
  spec.add_development_dependency "guard-rspec", "~> 4.6"

  case Gem::Platform.local.os
  # OSX 10.8+
  when /darwin-[1-9][2-9]|[2-9]\d/i
    spec.add_development_dependency "terminal-notifier-guard"
  when /mac|darwin/i
    spec.add_development_dependency "growl"
  when /linux|arch/i
    spec.add_development_dependency "libnotify", "~> 0.9"
  when /ms|win/i
    spec.add_development_dependency "rb-notifu"
  end

  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "english", "~> 0.6.3"
  spec.add_development_dependency "rubocop", "~> 0.34"
  spec.add_development_dependency "webmock", "~> 1.21"
end
