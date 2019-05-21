module TelegramBot
  class Bot
    ENDPOINT = 'https://api.telegram.org/'
    attr_reader :connection

    def initialize(opts = {})
      # compatibility with just passing a token
      opts = {token: opts} if opts.is_a?(String)

      @token = opts.fetch(:token)
      @base_path = "/bot#{@token}"
      @offset = opts[:offset] || 0
      @logger = opts[:logger] || NullLogger.new
      @connection = Connection.new(ENDPOINT, persistent: true, proxy: opts[:proxy])
    end

    def get_me
      @me ||= @connection
        .get(path: "#{@base_path}/getMe")
        .and_then { |result| User.new(result) }
        .value!
    end
    alias_method :me, :get_me
    alias_method :identity, :me

    def get_updates(**kwargs)
      return get_last_updates(**kwargs) unless block_given?

      kwargs[:timeout] ||= 50
      logger.info "starting get_updates loop"
      loop do
        messages = get_last_updates(**kwargs)
        kwargs[:offset] = @offset
        messages.compact.each do |message|
          next unless message
          logger.info "message from @#{message.chat.friendly_name}: #{message.text.inspect}"
          yield message
        end
      end
    end

    def send_message(chat_id:, text:, **kwargs)
      logger.info "sending message: #{text.inspect}"
      kwargs[:path] = "#{@base_path}/sendMessage"
      kwargs[:data] = {text: text, chat_id: chat_id}
      Message.new(post_message(**kwargs))
    end

    def kick_chat_member(chat_id:, user_id:, until_date: nil)
      logger.info "kicking chat member with id: #{user_id}"
      data = {chat_id: chat_id, user_id: user_id}
      data[:until_date] = until_date unless until_date.nil?
      post_message(path: "#{@base_path}/kickChatMember", data: data)
    end

    def unban_chat_member(chat_id:, user_id:)
      post_message(
        path: "#{@base_path}/unbanChatMember",
        data: {chat_id: chat_id, user_id: user_id}
      )
    end

    def set_webhook(url:, **kwargs)
      logger.info "setting webhook url to #{url}"
      post_message(path: "#{@base_path}/setWebhook", data: {url: url}, **kwargs)
    end

    def remove_webhook
      set_webhook("")
    end

    private
      attr_reader :logger

      def get_last_updates(fail_silently: nil, **kwargs)
        kwargs[:offset] ||= @offset

        response = @connection.get(path: "#{@base_path}/getUpdates", query: kwargs)
        if fail_silently && !response.ok?
          logger.warn "error when getting updates. ignoring due to fail_silently."
          return []
        end
        updates = response.value!.compact.map { |raw_update| Update.new(raw_update) }
        @offset = updates.last.id + 1 if updates.any?
        updates.map(&:get_update)
      end

      def post_message(path:, data: {}, content_type: nil, **kwargs)
        data.merge!(kwargs)
        if content_type.nil?
          content_type = "application/x-www-form-urlencoded"
          data = URI.encode_www_form(data)
        else
          content_type.downcase!
          if content_type == "application/json"
            data = JSON.dump(data)
          end
        end
        @connection.post(path: path, body: data, headers: {"Content-Type" => content_type}).value!
      end
  end
end
