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
          env.body = parse(env.body) if env.parse_body?
        rescue MultiJson::ParseError => exception
          raise Fakturan::Error::ParseError, {:status => env.status, :headers => env.response_headers, :body => env.body}
        end
      end
    end
  end
end