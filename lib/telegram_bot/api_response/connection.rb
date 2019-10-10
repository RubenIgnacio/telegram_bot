module TelegramBot
  module ApiResponse
    class Connection
      attr_accessor :content_type_default

      TELEGRAM_API = 'https://api.telegram.org/'
      APPLICATION_X_WWW_FORM_URLENCODED = 'application/x-www-form-urlencoded'
      APPLICATION_JSON = 'application/json'

      def initialize(token:, **kwargs)
        @content_type_default = APPLICATION_X_WWW_FORM_URLENCODED
        @base_path = "/bot#{token}"
        @connection = Excon.new(TELEGRAM_API, **kwargs)
      end

      def request(path, **kwargs)
        response = @connection.request(**kwargs.merge(path: "#{@base_path}/#{path}"))
        response = if response.status == 200
                     Response.new(response)
                   else
                     ResponseError.new(response)
                   end

        if block_given?
          yield response
        elsif response.ok?
          response
        else
          raise response
        end
      end

      def get(path, **kwargs, &block)
        request(path, method: :get, query: kwargs, &block)
      end

      def post(path, content_type: nil, **kwargs, &block)
        content_type = content_type_default if content_type.nil?
        content_type.downcase!
        if content_type == APPLICATION_X_WWW_FORM_URLENCODED
          kwargs = URI.encode_www_form(kwargs)
        elsif content_type == APPLICATION_JSON
          kwargs = JSON.dump(kwargs)
        end
        request(path, method: :post, body: kwargs, headers: {"Content-Type" => content_type}, &block)
      end
    end
  end
end
