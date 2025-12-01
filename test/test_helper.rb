require 'fakturan_nu'
require "minitest/autorun"
require 'minitest/reporters'
require 'webmock/minitest'
require 'json'
require 'vcr'
require 'minitest/around/unit'
require 'pry'
require 'byebug'

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

API_USER, API_PASS = 'jWE56VnOHqu-6HgaZyL2', 'LpdLorG0fmPRGOpeOvHSLiuloEHK0O8YsKliVPNY'

PROTOCOL = 'https://'

Fakturan.setup API_USER, API_PASS
Fakturan.use_sandbox = true
Fakturan.debug_log = false

BASE_URL = Fakturan.url.split(PROTOCOL).last # '0.0.0.0:3000/api/v2'
#WebMock.disable! # Do this if we want to run tests against server

#Fakturan.url = "http://#{BASE_URL}"

module WebMock
  module API
    def stub_api_request(method, abs_path)
      # stub_request(method, "#{PROTOCOL}#{API_USER}:#{API_PASS}@#{BASE_URL}#{abs_path}")
      stub_request(
        method,
        "#{PROTOCOL}#{BASE_URL}#{abs_path}")
        .with(
          :headers => {
            'Authorization'=>'Basic aldFNTZWbk9IcXUtNkhnYVp5TDI6THBkTG9yRzBmbVBSR09wZU92SFNMaXVsb0VISzBPOFlzS2xpVlBOWQ=='
          }
        )
    end
  end
end


