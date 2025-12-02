# -*- encoding: utf-8 -*-

require_relative 'lib/fakturan_nu/version'

Gem::Specification.new do |s|
  s.name        = 'fakturan_nu'
  s.version     = Fakturan::VERSION
  s.date        = '2015-05-11'
  s.summary     = 'A ruby client for the Fakturan.nu - API'
  s.description = 'A ruby client for the Fakturan.nu - API. Fakturan.nu is a webbapp for billing.'
  s.authors     = ['Jonathan Bourque Olivegren']
  s.email       = 'jonathan@imagineit.se'
  s.files       = `git ls-files`.split("\n") # http://www.codinginthecrease.com/news_article/show/350843?referrer_id=948927
  s.homepage    = 'https://github.com/imagine-it/fakturan-nu-gem'
  s.license       = 'MIT'

  s.required_ruby_version = '>= 2.7', '< 4.0'

  s.add_dependency 'spyke',              '~> 7.2', '>= 7.2.2'
  s.add_dependency 'faraday',            '~> 1.10'
  s.add_dependency 'faraday_middleware', '~> 1.2'
  s.add_dependency 'multi_json',         '~> 1.11', '>= 1.11.0'
  s.add_dependency 'activemodel',        '~> 6.1.0'
  s.add_dependency 'concurrent-ruby',    '~> 1.3', '< 1.3.5'
  s.add_dependency 'mutex_m'
  s.add_dependency 'base64'
  s.add_dependency 'logger'
  s.add_dependency 'benchmark'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-reporters'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'byebug'
end
