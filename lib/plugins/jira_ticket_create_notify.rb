# Check for newly created tickets in our feed db
class JiraTicketCreateNotify
  include Cinch::Plugin

  attr_accessor :db
  attr_reader :table

  timer 30, method: :ticket_notify

  def initialize(*args)
    # Connect to the database
    @db = SQLite3::Database.new('jruby_jira_rss.db')
    @db.results_as_hash = true   # Retrieve rows as a hash

    @table = 'new_tickets'

    super
  end


  def ticket_notify
    @db.execute("SELECT * FROM #{@table} WHERE shown_in_channel=0") do |tkt|
      
      #  (Author) created (Ticket) at (19-Nov-2010 21:17)
      #  (Ticket Summary)
      #  http://jira.codehaus.org/browse/(Ticket)
      Channel(config[:channel]).send("#{tkt['ticket_author']} created #{tkt['ticket']} at #{tkt['created_at']}")
      Channel(config[:channel]).send("  #{tkt['ticket_summary']}")
      Channel(config[:channel]).send("  http://jira.codehaus.org/browse/#{tkt['ticket']}")
      @db.execute("UPDATE #{@table} SET shown_in_channel=1 WHERE uuid='#{tkt['uuid']}'")
    end 
  end

  def execute(m)
    m.reply "Something is wrong if you are seeing this message"
  end

end
