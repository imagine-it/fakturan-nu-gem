require 'test_helper'

module Fakturan
  class BasicsTest < Minitest::Test

    def test_auth_with_token_and_back_to_basic
      VCR.turned_off do
        basic_auth_endpoint = stub_api_request(
          :get, '/clients/1'
        ).to_return(
          body: '{"data":{"id": 1, "name":"DCT"}}',
          status: 200
        )
  
        token_endpoint = stub_request(
          :get, "#{PROTOCOL}#{BASE_URL}/clients/1"
        ).with(
          headers: { authorization: "Token token=\"XYZ\""}
        ).to_return(
          body: '{"data":{"id": 1, "name":"DCT"}}',
          status: 200
        )
        Fakturan.use_basic_auth
        Fakturan::Client.find(1)
        Fakturan.use_token_auth('XYZ')
        Fakturan::Client.find(1)
        Fakturan.use_basic_auth
        Fakturan::Client.find(1)
        assert_requested basic_auth_endpoint, times: 2
        assert_requested token_endpoint, times: 1
      end
    end
  end
end
