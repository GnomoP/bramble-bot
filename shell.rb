#!/usr/bin/env ruby

require 'notify-send'
require 'readline'

class Object

  def is_num?
    true if Float(self) rescue false
  end

end

class Shell

  def initialize bot, config
    @bot = bot
    @cfg = config
    @read = Readline
    @list = config["shell_commands"]

    @read.completion_append_character = " "
    @read.completion_proc = proc { |s| @read::HISTORY.grep(/^\S/) }

  end

  def create_loop
    while input = @read.readline(">> ", true)

      @hist = @read::HISTORY
      args = input.split(" ")

      @hist.pop and next if input == "" or input.match('^\s+$')

      # Command-line functions
      def ping id: @cfg["commands_channel"], user: @cfg["bot_owner_id"], time: Time.now
        id = @bot.pm_channel(id).id if @bot.pm_channel(id) rescue id
        timespan = (Time.now - time).round(6) * 1000
        mention = @bot.user(user).mention
        @bot.send_message(id, "#{mention} ping! `#{timespan.round(3)}ms`")
      end

      def send name: nil, id: @cfg["bot_owner_id"], say: "boop"
        id = @cfg["channel"][name.to_s] if @cfg["channel"][name.to_s] rescue id
        id = @bot.pm_channel(id).id if @bot.pm_channel(id) rescue id
        @bot.send_message(id, say)
      end

      def doot id: @cfg["bot_owner_id"], server: @cfg["commands_server"], quant: 1, leave: true, file: "snd/doot.m4a"
        begin
          member = @bot.server(server).member(id)
          channel = member.voice_channel
          raise Exception.new("Not in a voice chat") unless channel

          voice = @bot.voices[server] || @bot.voice_connect(channel)
          quant.times { voice.play_file(file) }
          voice.destroy if leave
        rescue Exception => e
          NotifySend.send summary: e.backtrace[0],
                          body: e.message,
                          icon: "dialog-warning",
                          timeout: 5000
          voice.destroy rescue nil
        end
      end

      def history id: @cfg["commands_channel"], quant: 100
        channel = @bot.pm_channel(id).id if @bot.pm_channel(id) rescue nil
        channel ||= @bot.channel(id)
        channel.history(quant)
      end

      def purge id: @cfg["commands_channel"], quant: 100
        channel = @bot.pm_channel(id).id if @bot.pm_channel(id) rescue nil
        channel ||= @bot.channel(id)

        channel.delete_messages(channel.history(quant))
      end

      def read id: @cfg["commands_channel"], quant: 10
        channel = @bot.pm_channel(id).id if @bot.pm_channel(id) rescue nil
        channel ||= @bot.channel(id)
        channel.history(quant).reverse_each do |m|
          next if m.content == "" or m.content =~ /^\s+$/m
          puts "\r#{m.author.name}: #{m.content}"
        end
      end

      def roll dies: 2, sides: 6
        dies = dies.to_i
        sides = sides.to_i

        dies = 1   unless dies  < 10e10 and dies  > 0
        sides = 20 unless sides < 10e10 and sides > 1

        rolls = Array.new(dies) { rand(1..sides) }
        if dies > 1
          sum = rolls.reduce(:+)
          puts "Rolled #{rolls}; sum is #{sum}"
        else
          puts "Rolled #{rolls}"
        end
      end

      begin
        eval(input)
      rescue Exception => e
        puts e.message
        puts e.backtrace[0]
      else
        puts "Done."
      end

    end
  end

end