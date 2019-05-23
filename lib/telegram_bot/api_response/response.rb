module TelegramBot
  module ApiResponse
    class Response
      attr_reader :response, :data, :headers, :body

      def initialize(response)
        @response = response
        @data = response.data
        @headers = response.headers
        @body = JSON.parse(response.body)
      end

      def ok?
        true
      end

      def result
        body['result']
      end
    end
  end
end
