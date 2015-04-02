# -*- encoding: utf-8 -*-
require 'spyke'
#require 'active_support/json/decoding' # if we want date-strings to be typecast as DateTimes. Can be done through Faraday-middleware too.
require 'faraday_middleware'
require 'multi_json'
require 'fakturan_nu/spyke_extensions'
require 'fakturan_nu/middleware/parse_json'
require 'fakturan_nu/middleware/raise_error'

require 'fakturan_nu/base'
require 'fakturan_nu/address'
require 'fakturan_nu/product'
require 'fakturan_nu/client'
require 'fakturan_nu/row'
require 'fakturan_nu/invoice'

I18n.load_path += Dir.glob( File.dirname(__FILE__) + "lib/locales/*.{rb,yml}" )

module Fakturan
  @use_sandbox = false
  @api_version = 2

  mattr_accessor :accept_language

  def self.setup username = nil, pass = nil
    #self.parse_json_times = true

    @username, @pass = username, pass
    self.accept_language = 'en-US'

    @connection = Faraday.new(url: build_url) do |connection|
      # Request
      connection.request :json
      connection.use Faraday::Request::BasicAuthentication, @username, @pass

      # Response
      connection.use Fakturan::Response::ParseJSON
      connection.use Fakturan::Response::RaiseError

      # Adapter should be last
      connection.adapter Faraday.default_adapter
    end
  end

  def self.connection
    @connection
  end

  #def self.parse_json_times=(true_or_false)
  #  ActiveSupport.parse_json_times = true_or_false
  #end

  def self.use_token_auth(token)
    @connection.token_auth(token)
  end

  def self.use_basic_auth(username = nil, pass = nil)
    @username, @pass = username, pass if (username && pass)
    @connection.basic_auth(@username, @pass)
  end

  def self.use_sandbox=(true_or_false)
    @use_sandbox = true_or_false
    rebuild_url
  end

  def self.api_version=(version_no)
    @api_version = version_no
    rebuild_url
  end

  def self.url
    @connection.url_prefix.to_s
  end

  def self.url=(new_url)
    @connection.url_prefix = new_url
  end

  def self.build_url
    "https://#{@use_sandbox ? 'sandbox.' : ''}fakturan.nu/api/v#{@api_version}"
  end

  def self.rebuild_url
    self.url = self.build_url
  end
end