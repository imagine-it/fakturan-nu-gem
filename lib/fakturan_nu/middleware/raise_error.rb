require 'fakturan_nu/error'

module Fakturan
  module Response
    class RaiseError < Faraday::Response::Middleware
      ClientErrorStatuses = 400...499
      ServerErrorStatuses = 500...599

      def on_complete(env)
        case env[:status]
        when 401
          raise Fakturan::Error::AccessDenied, response_values(env)
        when 404
          raise Fakturan::Error::ResourceNotFound, response_values(env)
        when 407
          # mimic the behavior that we get with proxy requests with HTTPS
          raise Faraday::ConnectionFailed, %{407 "Proxy Authentication Required "} # We raise this instead of our own ConnectionFailed error, since Faraday::ConnectionFailed will be raise on timeouts or refused connections anyway
        when 422
          # We don't do anything except fallback to standard behaviour in Spyke, which is to store errors on .errors and not raise an exception
          # If an exception is desirable, then use .save! on the model instead of .save.
        when ClientErrorStatuses
          raise Fakturan::Error::ClientError, response_values(env)
        when ServerErrorStatuses
          raise Fakturan::Error::ServerError, response_values(env)
        end
      end

      def response_values(env)
        {:status => env.status, :headers => env.response_headers, :body => env.body}
      end
    end
  end
end