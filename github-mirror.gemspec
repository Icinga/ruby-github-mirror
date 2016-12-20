# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'github-mirror'
  spec.version       = '0.0.0'
  spec.authors       = ['Markus Frosch']
  spec.email         = ['markus@lazyfrosch.de']

  spec.summary       = 'Mirroring repositories from GitHub to elsewhere'
  spec.description   = 'Mirroring and backup for GitHub repository to another Git installation'
  spec.homepage      = 'https://github.com/lazyfrosch/ruby-github-mirror'
  spec.license       = 'GPL-2+'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'github_api', '~> 0.14'
  spec.add_dependency 'deep_merge', '~> 1.1'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake',    '~> 10.0'
  # spec.add_development_dependency 'rspec',   '~> 3.0'

  if RUBY_VERSION >= '2.3'
    spec.add_development_dependency 'rubocop', '>= 0.45.0'
  end
end
