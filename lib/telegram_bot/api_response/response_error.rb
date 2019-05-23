module TelegramBot
  module ApiResponse
    class ResponseError < StandardError
      attr_reader :response, :data, :headers, :body

      def initialize(response)
        @response = response
        @data = response.data
        @headers = response.headers
        @body = begin
          JSON.parse(response.body)
        rescue JSON::ParserError
          {'ok': false, 'error_code': response.status}
        end
      end

      def ok?
        false
      end

      def error_code
        body['error_code']
      end

      def description
        body['description']
      end
    end
  end
end
