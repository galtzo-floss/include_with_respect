lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'include_with_respect/version'

Gem::Specification.new do |spec|
  spec.name          = 'include_with_respect'
  spec.version       = IncludeWithRespect::VERSION
  spec.authors       = ['Peter Boling']
  spec.email         = ['peter.boling@gmail.com']

  spec.summary       = 'Untangle dependency trees'
  spec.description   = 'Find out if your Module include/extend hooks are misbehaving!'
  spec.homepage      = 'http://github.com/pboling/include_with_respect'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 1.9.2'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'http://github.com/pboling/include_with_respect'
  spec.metadata['changelog_uri'] = 'http://github.com/pboling/include_with_respect/blob/master/CHANGELOG'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'debug'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'gem-release', '~> 2.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-block_is_expected'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'silent_stream'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'wwtd'
end
