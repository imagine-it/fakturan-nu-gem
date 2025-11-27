# frozen_string_literal: true

# This is just to provide a set of errors with consistent scope
# https://github.com/lostisland/faraday/blob/master/lib/faraday/error.rb
module Fakturan
  class Error < StandardError; end

  class WithResponse < Error
    attr_reader :response

    def status
      response[:status]
    end
    
    def initialize(ex, response = nil)
      @wrapped_exception = nil
      @response = response

      if ex.respond_to?(:backtrace) # If ex behaves like an Exception
        super(ex.message)
        @wrapped_exception = ex
      elsif ex.respond_to?(:each_key) # If ex behaves like a Hash
        super("the server responded with status #{ex[:status]} - #{ex[:body]}")
        @response = ex
      else
        super(ex.to_s)
      end
    end

    def backtrace
      if @wrapped_exception
        @wrapped_exception.backtrace
      else
        super
      end
    end

    def inspect
      %(#<#{self.class}>)
    end
  end

  class ClientError      < WithResponse; end
  class ServerError      < WithResponse; end
  class AccessDenied     < WithResponse; end
  class ResourceNotFound < WithResponse; end
  class ParseError       < WithResponse; end

  class ConnectionFailed < Error
    def status; 407; end
  end

  class ResourceInvalid < Error
    attr_reader :model

    def status; 422; end

    def initialize(model)
      @model = model
      msg = @model.errors.details #to_a.join(" ")
      super(msg)
    end
  end

  # This is just so that we can have Fakturan::Error be both a class and a "scope": Fakturan::Error::ResourceInvalid
  [:WithResponse, :ClientError, :ServerError, :AccessDenied, :ResourceNotFound, :ParseError, :ConnectionFailed, :ResourceInvalid].each do |const|
    Error.const_set(const, Fakturan.const_get(const))
  end
end