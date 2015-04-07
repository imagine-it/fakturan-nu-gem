require 'fakturan_nu'
require "minitest/autorun"
require 'minitest/reporters'
require 'webmock/minitest'
require 'json'
require 'vcr'
require 'minitest/around/unit'

# If we want to get VCR to save responses as json instead of binary (only happens sometimes):
# https://groups.google.com/forum/#!topic/vcr-ruby/2sKrJa86ktU
# http://stackoverflow.com/questions/21920259/how-to-edit-response-body-returned-by-vcr-gem

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock
  
  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end
end

# Pretty colors
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

API_USER, API_PASS = 'dUmziS9k9Q5x0u4wot1H', 'DAW96mbxui8B3_CBFFFMr0HgfaCfpv7ajUfcZ38B'
BASE_URL = '0.0.0.0:3000/api/v2'
#WebMock.disable! # Do this if we want to run tests against local server

Fakturan.setup API_USER, API_PASS
Fakturan.url = "http://#{BASE_URL}"

module WebMock
  module API
    def stub_api_request(method, abs_path)
      stub_request(method, "http://#{API_USER}:#{API_PASS}@#{BASE_URL}#{abs_path}")
    end
  end
end


