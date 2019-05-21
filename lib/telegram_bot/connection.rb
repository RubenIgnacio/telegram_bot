module TelegramBot
  class Connection
    attr_reader :connection

    def initialize(url, params = {})
      @connection = Excon.new(url, params)
    end

    def request(params = {}, &block)
      response = @connection.request(params, &block)
      ApiResponse.from_excon(response)
    end

    Excon::HTTP_VERBS.each do |method_name|
      class_eval <<-DEF, __FILE__, __LINE__ + 1
        def #{method_name}(params = {}, &block)
          request(params.merge(method: #{method_name.inspect}), &block)
        end
      DEF
    end
  end
end
