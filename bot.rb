require 'cinch'
require 'hpricot'
require 'net/http'
require 'uri'
require 'sqlite3'

load 'cinch_timer.rb'


# Check for newly created tickets in our feed db
class JiraTicketCreateNotify
  include Cinch::Plugin

  attr_accessor :db
  attr_reader :table

  timer 5, method: :ticket_notify

  def initialize(*args)
    # Connect to the database
    @db = SQLite3::Database.new('jruby_jira_rss.db')
    @db.results_as_hash = true   # Retrieve rows as a hash

    @table = 'new_tickets'

    super
  end


  def ticket_notify
    @db.execute("SELECT * FROM #{@table} WHERE shown_in_channel=0") do |tkt|
      
      #  (Jeremy Evans) created (JRUBY-5199) at (19-Nov-2010 21:17)
      #  (Update OpenBSD FFI files and JFFI jars)
      #  http://jira.codehaus.org/browse/(JRUBY-5199)
      Channel(config[:channel]).send("#{tkt['ticket_author']} created #{tkt['ticket']} at #{tkt['created_at']}")
      Channel(config[:channel]).send("#{tkt['ticket_summary']}")
      Channel(config[:channel]).send("http://jira.codehaus.org/browse/#{tkt['ticket']}")
      @db.execute("UPDATE #{@table} SET shown_in_channel=1 WHERE uuid='#{tkt['uuid']}'")
    end 
  end

  def execute(m)
    m.reply "This shit is b0rked"
  end

end


config = Hash.new
config[:channel] = "#cinch-bots"

bot = Cinch::Bot.new do

  configure do |c|
    c.nick              = "jruby-jira-test"
    c.server            = "irc.freenode.net"
    c.verbose           = true
    c.plugins.plugins   = [JiraTicketCreateNotify]

    c.plugins.options[JiraTicketCreateNotify][:channel] = config[:channel]
  end

  on :connect do
    bot.join config[:channel]
    bot.privmsg "nickserv", "IDENTIFY jrubyb0tp4ss"
  end

  # Respond to message without the Jira ticket
  on :message, /^!jira (.+)/ do |msg, query|
    find_jira(msg, query)
  end

  # Respond to the user with a help menu
  on :message, /^!help/ do |msg|
    send_help(msg)
  end

  helpers do
    
    def find_jira(msg, query)
      url = "http://jira.codehaus.org/browse/#{query.upcase}"
      target_html = Net::HTTP.get(URI.parse(url))

      doc = Hpricot(target_html)

      if doc.at('title').inner_text =~ /Issue Does Not Exist/
        msg.reply "No such ticket"
        return
      end
  
      # Title xpath
      issue_title = doc.at('//*[@id="issue_header_summary"]').inner_text.strip

      # Type xpath
      type = doc.at('//*[@id="type-val"]').inner_text.strip

      # Status xpath
      status = doc.at('//*[@id="status-val"]').inner_text.strip

      msg.reply "[#{type}:#{status}] #{issue_title}"
      msg.reply "#{url}"
    end

    # Send the help message to a user
    def send_help(msg)
      username = User(msg.user)
      bot.privmsg "#{username}", "To see this message:"
      bot.privmsg "#{username}", "  !help"

      bot.privmsg "#{username}", "To see a jira ticket, type:"
      bot.privmsg "#{username}", "  !jira <ticket>"
      bot.privmsg "#{username}", "  !jira JRUBY-5182"
    end

  end

end

bot.start
