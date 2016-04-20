module Fakturan
  module Response
    class ParseJSON < Faraday::Response::Middleware
      def parse(body)
        json = MultiJson.load(body, symbolize_keys: true)

        res = {
          data: json[:data],
          metadata: json[:paging],
          errors: json[:errors]
        }
        return res
      end

      def on_complete(env)
        begin # https://github.com/lostisland/faraday/blob/master/lib/faraday/response.rb
          if env.parse_body? # If we get a result
            env.body = parse(env.body)
          else # If we get 204 = request fine, but no content returned
            env.body = { data: {}, metadata: {}, errors: {} }
          end
        rescue MultiJson::ParseError
          raise Fakturan::Error::ParseError, {:status => env.status, :headers => env.response_headers, :body => env.body}
        end
      end
    end
  end
end