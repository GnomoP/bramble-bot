#!/usr/bin/env ruby

require 'notify-send'
require 'discordrb'
require 'open-uri'
require 'json'
require './shell'

rootfp = File.expand_path(File.dirname(__FILE__))
File.open(rootfp + '/config.json', 'r+') do |f|
  if f.read.empty?
    default = ['{', '  "client_id": "",', '  "bot_token": ""', '}']
    f.write(default.join "\n")
  end

  f.rewind
  BOT_CONFIG = JSON.parse(f.read)
end

class CommandBot < Discordrb::Commands::CommandBot; end

PREFIXES = BOT_CONFIG["prefixes"].freeze
prefix = proc do |message|
  if message.channel.server
    prefix = PREFIXES[message.channel.server.id] || ">>"
  else
    prefix = PREFIXES[message.author.id] || 
            PREFIXES[message.channel.id] || ">>"
  end

  message.content[prefix.size..-1] if message.content.start_with?(prefix)
end

bot = CommandBot.new token: BOT_CONFIG["bot_token"],
      client_id: BOT_CONFIG["client_id"],
      prefix: prefix,
      parse_self: BOT_CONFIG["parse_self"]

bot.command :ping do |event|
  mention = event.author.mention
  time = (Time.now - event.timestamp).round(6) * 1000
  "#{mention} ping! `#{time.round(3)}ms`"
end

bot.command :echo do |event, *text|
  break unless event.user.id == BOT_CONFIG["bot_owner_id"]

  text.join(' ')
end

bot.command :reboot do |event|
  break unless event.user.id == BOT_CONFIG["bot_owner_id"]

  event.message.react("👋")
  exit 0
end

bot.command :exit do |event|
  break unless event.user.id == BOT_CONFIG["bot_owner_id"]

  event.message.react("👋")
  exit 1
end

ignore = [bot.user(BOT_CONFIG["bot_owner_id"]).name, bot.user(BOT_CONFIG["client_id"]).name]
bot.message from: not!(ignore) do |m|
  next unless m.channel.pm?

  next if m.content == "" or m.content =~ /^\s+$/m  
  next if m.author.id == BOT_CONFIG["client_id"]

  begin
    head = "#{m.author.username}\##{m.author.discriminator} said:"
    body = m.content
    icon = "discord"
    time = 0.5e5
  rescue Exception => e
    head = e.backtrace[0]
    body = e.message
    icon = "dialog-warning"
    time = 1e5
  end

  NotifySend.send summary: head, body: body, timeout: time, icon: icon
end

bot.run :async

shell = Shell.new(bot, BOT_CONFIG)
shell.create_loop()
