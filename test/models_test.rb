require 'test_helper'
VCR.turn_on!


module Fakturan
  class ModelsTest < MiniTest::Test

    def around(&block)
      # https://www.relishapp.com/vcr/vcr/v/2-9-3/docs/request-matching/playback-repeats
      VCR.use_cassette("models", 
        :allow_playback_repeats => true, 
        #:record => :new_episodes, 
        :match_requests_on => [:method, :uri, :body],
        &block)
    end

    # They are not, but I dislike them jumping around in the output. Makes it harder to compare two test runs.
    i_suck_and_my_tests_are_order_dependent!

    def good_invoice_params
      @good_invoice_params  ||= { client: { company: 'Imagine it AB' }, date: "2015-04-07".to_date, address: { name: "Imagine it AB", street_address: "Tage Erlandergatan 4" } }
    end

    def get_good_invoice
      return if @invoice # We won't change this instance so we really only need to do this once.
      @invoice = Fakturan::Invoice.find(5)
    end

    def test_find_one_and_access_attribute
      client = Fakturan::Client.find(1)
      assert client.name.is_a? String
    end

    def test_should_create_associated_objects
      get_good_invoice
      assert_equal @invoice.address.name, 'A simple client'
    end

    def test_should_be_able_to_fetch_and_update_invoice
     #skip "Not implemented server side yet"
     invoice = Fakturan::Invoice.find(10)
     invoice.days = 10
     assert invoice.save
    end

    def test_should_fetch_associated_record
      get_good_invoice
      client = Fakturan::Client.find(11)
      assert_equal Fakturan::Client, client.class
      assert_equal 'A simple client', client.name
      assert_equal client.name, @invoice.client.name
    end

    def test_find_one_and_access_attribute
     products = Fakturan::Product.all
     assert products.first.product_code.is_a? String
    end

    def test_get_collection
      products = Fakturan::Product.all
      assert_equal Fakturan::Product, products.first.class
      assert products.first.is_a? Fakturan::Product
      assert_equal 25, products.first.tax
      assert_equal Fixnum, products.first.tax.class
    end

    def test_save_should_return_false_then_true
      p = Fakturan::Product.new
      assert_equal false, p.save
      p.name = "Testing"
      assert_equal true, p.save
    end

    def test_should_fetch_associated_records
     skip "Not implemented server side yet"
     client = Fakturan::Client.find(1)
     assert_equal Fakturan::Invoice, client.invoices.first.class # Currently gives routing error
    end

    def test_save_new_product
      p = Fakturan::Product.new(name: "Shoes")
      assert p.save
    end

    def test_create_should_return_instance_when_successful
      invoice = Fakturan::Invoice.create good_invoice_params
      assert_equal Fakturan::Invoice, invoice.class
    end

    def test_create_should_return_instance_when_unsuccessful
      invoice = Fakturan::Invoice.create
      assert_equal Fakturan::Invoice, invoice.class
    end

    def test_create_bang_should_return_nil_when_unsuccessful
      begin
        invoice = Fakturan::Invoice.create!
      rescue
      end
      assert_equal nil, invoice
    end

    def test_create_bang_should_return_instance_when_successful
      begin
        invoice = Fakturan::Invoice.create! good_invoice_params
      rescue
      end
      assert_equal Fakturan::Invoice, invoice.class
    end

    def test_date_fields_should_not_be_typecast
      get_good_invoice
      assert_equal String, @invoice.date.class
    end

    def test_getting_attribute_on_new_instance
      invoice = Fakturan::Invoice.new
      # Would blow up unless attributes are specified on model
      assert_nil invoice.number
    end

    def test_should_be_able_to_set_params_on_association
      invoice = Fakturan::Invoice.new
      invoice.date = "2015-04-07"
      invoice.build_client
      invoice.client.company = 'Imagine it AB'
      assert invoice.save
    end

    def test_calling_association_on_non_persisted_invoice_should_make_no_request
      invoice = Fakturan::Invoice.new
      begin
        invoice.client
      rescue Spyke::InvalidPathError
        # Spyke throws this error because we are asking for an associated object without providing
        # required params in url 'client/:id'
      end
      assert_not_requested :get, "http://#{API_USER}:#{API_PASS}@#{BASE_URL}/#{Fakturan::Client.new.uri}"
    end

  end
end