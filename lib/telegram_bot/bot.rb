module TelegramBot
  class Bot
    def initialize(opts = {})
      # compatibility with just passing a token
      opts = {token: opts} if opts.is_a?(String)

      @token = opts.fetch(:token)
      @offset = opts[:offset] || 0
      @logger = opts[:logger] || NullLogger.new
      @connection = ApiResponse.new(token: @token, persistent: true, proxy: opts[:proxy])
    end

    def get_me
      @me ||= User.new(@connection.get(:getMe).result)
    end

    alias_method :me, :get_me
    alias_method :identity, :me

    def get_updates(**kwargs)
      kwargs[:timeout] ||= 50
      logger.info "starting get_updates loop"
      loop do
        updates = get_last_updates(**kwargs)
        @offset = updates.last.id + 1 if updates.any?
        messages = updates.map(&:get_update)

        break messages unless block_given?
        messages.each do |message|
          next unless message
          logger.info "message from @#{message.chat.friendly_name}: #{message.text.inspect}"
          yield message
        end
        kwargs[:offset] = @offset
      end
    end

    def send_message(chat_id:, text:, **kwargs)
      logger.info "sending message: #{text.inspect}"
      response = @connection.post(:sendMessage, **kwargs.merge(chat_id: chat_id, text: text))
      Message.new(response.result)
    end

    def kick_chat_member(chat_id:, user_id:, **kwargs)
      logger.info "kicking chat member with id: #{user_id}"
      @connection.post(:kickChatMember, **kwargs.merge(chat_id: chat_id, user_id: user_id)).result
    end

    def unban_chat_member(chat_id:, user_id:)
      logger.info "unban chat member with id: #{user_id}"
      @connection.post(:unbanChatMember, chat_id: chat_id, user_id: user_id).result
    end

    def restrict_chat_member(chat_id:, user_id:, **kwargs)
      @connection.post(:restrictChatMember, **kwargs.merge(chat_id: chat_id, user_id: user_id)).result
    end

    def promote_chat_member(chat_id:, user_id:, **kwargs)
      @connection.post(:promoteChatMember, **kwargs.merge(chat_id: chat_id, user_id: user_id)).result
    end

    def get_chat(chat_id:)
      Chat.new(@connection.get(:getChat, chat_id: chat_id).result)
    end

    def set_webhook(url:, **kwargs)
      logger.info "setting webhook url to #{url}"
      @connection.post(:setWebhook, url: url, **kwargs).result
    end

    def remove_webhook
      set_webhook("")
    end

    private
      attr_reader :logger

      def get_last_updates(fail_silently: nil, **kwargs)
        kwargs[:offset] ||= @offset
        @connection.get(:getUpdates, **kwargs) do |response|
          if response.ok?
            response.result.map { |result| Update.new(result) }
          elsif fail_silently
            logger.warn "error when getting updates. ignoring due to fail_silently."
            []
          else
            raise response
          end
        end
      end
  end
end
