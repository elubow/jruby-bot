require 'cinch'
require_relative 'lib/cinch_extras'

require 'hashie'
require_relative 'lib/plugins'


config = Hashie::Mash.new
config.nick = "jruby-bot"
config.channel = "#jruby"
config.freenode_pass = "jrubyb0tp4ss"

bot = Cinch::Bot.new do

  configure do |c|
    c.nick              = config.nick
    c.server            = "irc.freenode.net"
    c.verbose           = true
    c.plugins.plugins   = [FindJiraTicket, JiraTicketCreateNotify, JiraTicketCreateNotifyCrons, SendHelp]

    c.plugins.options[JiraTicketCreateNotify][:channel] = config.channel
  end

  on :connect do
    bot.join config[:channel]
    bot.privmsg "nickserv", "IDENTIFY #{config.freenode_pass}"
  end

end

bot.start
