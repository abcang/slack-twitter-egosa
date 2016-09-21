# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slack_twitter_egosa/version'

Gem::Specification.new do |spec|
  spec.name          = 'slack_twitter_egosa'
  spec.version       = SlackTwitterEgosa::VERSION
  spec.authors       = ['ABCanG']
  spec.email         = ['abcang1015@gmail.com']

  spec.summary       = 'Eegosearching twitter and post to slack.'
  spec.description   = 'Eegosearching twitter and post to slack.'
  spec.homepage      = 'https://github.com/ABCanG/slack-twitter-egosa'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dotenv', '~> 2.1.1'
  spec.add_dependency 'slack-poster', '~> 2.2.0'
  spec.add_dependency 'tweetstream', '~> 2.6.1'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
