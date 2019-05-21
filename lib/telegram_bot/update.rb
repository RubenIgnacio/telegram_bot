module TelegramBot
  class Update
    include Virtus.model
    attribute :update_id, Integer
    alias_method :id, :update_id
    alias_method :to_i, :id
    attribute :message, Message
    attribute :edited_message, Message
    attribute :channel_post, Message
    attribute :edited_channel_post, Message

    def get_update
      attributes.select { |k, v| v if k != :update_id }.values.first
    end
  end
end
