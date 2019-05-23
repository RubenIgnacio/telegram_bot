require 'excon'
require 'virtus'
require 'json'
require "telegram_bot/version"
require "telegram_bot/null_logger"
require "telegram_bot/api_response"

module TelegramBot
  {
    User: "user",
    Chat: "chat",
    MessageEntity: "message_entity",
    Message: "message",
    Keyboard: "keyboard",
    ReplyKeyboardHide: "reply_keyboard_hide",
    ReplyKeyboardMarkup: "reply_keyboard_markup",
    ForceReplay: "force_replay",
    Update: "update",
    Bot: "bot",
  }.each do |key, val|
    autoload(key, "telegram_bot/#{val}")
  end

  def self.new(opts)
    Bot.new(opts)
  end
end
