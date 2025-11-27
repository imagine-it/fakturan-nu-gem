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

  s.add_dependency 'spyke',       '~> 4.1',  '>= 4.1.1'
  s.add_dependency 'faraday',     '>= 0.8',  '< 1.0'
  s.add_dependency 'multi_json',  '~> 1.11', '>= 1.11.0'
  s.add_dependency 'activemodel', '~> 5.2',  '< 6.0'

  s.add_development_dependency 'bigdecimal', '~> 1.4.0'
  s.add_development_dependency 'rake', '~> 10.5.0'
  s.add_development_dependency 'pry', '~> 0.10'
  s.add_development_dependency 'webmock', '~> 1.24.0'
  s.add_development_dependency 'minitest', '~> 5.15.0'
  s.add_development_dependency 'minitest-reporters', '~> 1.7.0'
  s.add_development_dependency 'minitest-around', '~> 0.5.0'
  s.add_development_dependency 'vcr', '~> 2.9.0'
  s.add_development_dependency 'byebug'
end