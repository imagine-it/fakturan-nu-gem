# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = 'fakturan_nu'
  s.version     = '1.0.0'
  s.date        = '2014-12-17'
  s.summary     = 'A ruby client for the Fakturan.nu - API'
  s.description = 'A ruby client for the Fakturan.nu - API. Fakturan.nu is a webbapp for billing.'
  s.authors     = ['Jonathan Bourque Olivegren']
  s.email       = 'jonathan@imagineit.se'
  s.files       = `git ls-files`.split("\n") # http://www.codinginthecrease.com/news_article/show/350843?referrer_id=948927
  s.homepage    = 'http://rubygems.org/gems/fakturan_nu'
  s.license       = 'MIT'

  s.add_dependency 'spyke',   '~> 1.8', '>= 1.8.7'
  s.add_dependency 'faraday', '>= 0.8', '< 1.0'
  s.add_dependency 'multi_json', '~> 1.11', '>= 1.11.0'
  # So we can use model.errors.details before Rails 5.
  s.add_dependency 'active_model-errors_details', '~> 1.1', '>= 1.1.1'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-reporters'
  s.add_development_dependency 'minitest-around'
  s.add_development_dependency 'vcr'
end