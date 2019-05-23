require 'telegram_bot/api_response/response'
require 'telegram_bot/api_response/response_error'
require 'telegram_bot/api_response/connection'

module TelegramBot
  module ApiResponse
    def self.new(**kwargs)
      Connection.new(**kwargs)
    end
  end
end
