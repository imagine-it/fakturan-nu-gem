require 'test_helper'
require 'fixtures'

VCR.turn_off!

module Fakturan
  class ExceptionsTest < MiniTest::Test

    # They are not, but I dislike them jumping around in the output. Makes it harder to compare two test runs.
    i_suck_and_my_tests_are_order_dependent!

    def test_raise_access_denied
      stub_api_request(:get, '/clients/1').to_return(body: 'some json', status: 401)
      error = assert_raises Fakturan::Error::AccessDenied do
        Fakturan::Client.find(1)
      end
      assert_equal 401, error.status
    end

    def test_raise_resource_not_found
      stub_api_request(:get, '/clients/0').to_return(body: '{"error":"404 Not Found"}', status: 404)
      error = assert_raises Fakturan::Error::ResourceNotFound do
        Fakturan::Client.find(0)
      end
      assert_equal 404, error.status
    end

    def test_raise_parse_error
      stub_api_request(:get, '/clients/0').to_return(body: ')!"#/€!)"=#€()', status: 200)
      error = assert_raises Fakturan::Error::ParseError do
        Fakturan::Client.find(0)
      end
      assert error.response.is_a? Hash
      assert_equal 200, error.status
    end

    def test_raise_failed_connection
      old_url = Fakturan.url
      WebMock.disable!
      Fakturan.url = 'http://0.0.0.0:1234' # I sure hope no one responds here. ;)
      error = assert_raises Fakturan::Error::ConnectionFailed do
        Fakturan::Client.find(1)
      end
      WebMock.enable!
      Fakturan.url = old_url
      assert_equal 407, error.status
    end

    def test_raise_timeout_error
      stub_api_request(:get, '/clients/1').to_timeout
      error = assert_raises Fakturan::Error::ConnectionFailed do
        Fakturan::Client.find(1)
      end
      assert_equal 407, error.status
    end

    def test_raise_server_error_on_internal_server_error
      stub_api_request(:get, '/clients/1').to_return(body: { error: '500 Internal server error' }.to_json, status: 500)
      error = assert_raises Fakturan::Error::ServerError do
        Fakturan::Client.find(1)
      end
      assert_equal 500, error.status
    end

    def test_raise_client_error_on_bad_request # Don't think the api actually ever responds with a plain 400 a t m, but anyway...
      stub_api_request(:post, '/invoices').to_return(body: { error: '400 Bad request' }.to_json, status: 400)
      error = assert_raises Fakturan::Error::ClientError do
        Fakturan::Invoice.create client: { address: '' } # Address should really be a hash
      end
      assert_equal 400, error.status
    end

    def test_validation_errors_on_associations_when_created_through_params
      stub_api_request(:post, '/trees').to_return(body: {errors: {apples: [{"0" => {"apples.colour" => [{error: :blank}]}}], "crown.fluffyness" => [{error: :invalid}]}}.to_json, status: 422)

      a = Fakturan::Tree.new({"apples"=>[{"name"=>"zdsdfsdf", "email"=>"", "password"=>"", "firstname"=>"zdsdfsdf", "lastname"=>"zdsdfsdf", "colour"=>""}], "crown"=>{"fluffyness"=>""}})

      assert_equal false, a.save
      assert_equal (["Apples is invalid", "Crown fluffyness is invalid"]), a.errors.to_a
      assert_equal (["Fluffyness is invalid"]), a.crown.errors.to_a
    end

    def test_validation_errors_on_blank_associated_objects
      stub_api_request(:post, '/trees').to_return(body: {errors: {apples: [{error: :blank}], crown: [{error: :blank}]}}.to_json, status: 422)
      a = Fakturan::Tree.new()
      assert_equal false, a.save
      assert_equal (["Apples can't be blank", "Crown can't be blank"]), a.errors.to_a
      assert_equal ({:apples=>[{:error=>:blank}], :crown=>[{:error=>:blank}]}), a.errors.details
    end

    def test_save_fails_when_has_many_validation_fails
      stub_api_request(:post, '/invoices').to_return(body: {errors: {rows: [{"0" => {"rows.product_code" => [{error: :too_long, count:30}]}}] }}.to_json, status: 422)

      invoice = Fakturan::Invoice.new(client: { company: "Acme inc" }, rows: [{product_code: '1234567890123456789012345678901'}])

      assert_equal false, invoice.save
      assert_equal ({:product_code=>[{:error=>:too_long, :count=>30}]}), invoice.rows[0].errors.details
      assert_equal "Rows is invalid", invoice.errors.to_a.first
    end

    def test_validation_errors_on_associations
      stub_api_request(:post, '/invoices').to_return(body: {errors: {date: [{error: :blank},{error: :invalid}], rows: [{"0" => {"rows.product_code" => [{error: :too_long, count:30}]}}, {"2" => {"rows.product_code" => [{error: :too_long, count:30}]}}], "client.company" => [{ error: :blank}]}}.to_json, status: 422)

      invoice = Fakturan::Invoice.new(client: {}, rows: [{product_code: '1234567890123456789012345678901'}, {product_code: '1'}, {product_code: '1234567890123456789012345678901'}])
      invoice.save

      assert_equal "Client company can't be blank", invoice.errors.to_a.last
      assert_equal ({date: [{error: :blank}, {error: :invalid}], :rows=>[{:error=>:invalid}]}), invoice.errors.details
      assert_equal ({:product_code=>[{:error=>:too_long, :count=>30}]}), invoice.rows[0].errors.details
      # This one checks that our index / ordering has succeded and we have put the errors on the correct object
      assert_equal ({:product_code=>[{:error=>:too_long, :count=>30}]}), invoice.rows[2].errors.details
      assert_equal ({:company=>[{:error=>:blank}]}), invoice.client.errors.details
    end

    def test_raise_resource_invalid
      stub_api_request(:post, '/invoices').to_return(body: { errors: { client_id: [{ error: :blank}], date: [{ error: :blank}, { error: :invalid}] }}.to_json, status: 422)
      error = assert_raises Fakturan::Error::ResourceInvalid do
        Fakturan::Invoice.create!
      end
      assert_equal 422, error.status
      assert_equal "Client can't be blank", error.model.errors.to_a.first
      assert_raises Fakturan::Error::ResourceInvalid do
        Fakturan::Invoice.new.save!
      end
    end

    def test_errors_on_model
      stub_api_request(:post, '/invoices').to_return(body: { errors: { client_id: [{ error: :blank}], date: [{ error: :blank}, { error: :invalid}] }}.to_json, status: 422)
      invoice = Fakturan::Invoice.create
      assert_equal "Client can't be blank", invoice.errors.to_a.first
    end

  end
end