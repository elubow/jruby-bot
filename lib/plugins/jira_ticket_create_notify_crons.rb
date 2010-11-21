class JiraTicketCreateNotifyCrons
  include Cinch::Plugin

  attr_accessor :db
  attr_reader :table

  timer 20, method: :get_new_tickets

  def initialize(*args)
    # Connect to the database
    @db = SQLite3::Database.new('db/jruby_jira_rss.db')
    @db.results_as_hash = true   # Retrieve rows as a hash

    @table = 'new_tickets'

    db.execute("CREATE TABLE IF NOT EXISTS #{@table} (uuid string unique, ticket_summary string, ticket_author string, ticket string, created_at text, shown_in_channel int)")

    super
  end

  def get_new_tickets
    agent = Mechanize.new
    page = agent.get('http://jira.codehaus.org/secure/Dashboard.jspa')
    page = agent.click page.link_with(:text => /Log In/)
    
    form = page.form_with(:name => "loginform")
    form.os_username = 'elubow'
    form.os_password = 'dIt5Y42P'
    page = agent.submit(form)
    
    page = agent.get("http://jira.codehaus.org/plugins/servlet/streams?key=JRUBY&os_authType=basic")
    
    feed = Feedzirra::Feed.parse(page.body)
    
    new_item_re = %r|^<a href='http://jira.codehaus.org/secure/ViewProfile.jspa\?name=.+'>.+</a> created <a href="http://jira.codehaus.org/browse/JRUBY-.+">(JRUBY-.+)</a>(.+)$|
    
    feed.entries.each do |item|
      ticket = new_item_re.match(item.summary)
      # Skip if not a new ticket
      unless ticket
        next
      end
      
      created_at = DateTime.parse(item.updated).strftime('%d-%h-%G %H:%M')
      summary = "#{item.author} created #{ticket[1]} at #{created_at}"
    
      begin
        db.execute("INSERT INTO new_tickets VALUES('#{item.entry_id[9..-1]}', '#{clean_summary(ticket[2])}', '#{item.author}','#{ticket[1]}', '#{created_at}', 0)")
      rescue Exception => e
      end
    end
  end


  def execute(m)
    m.reply "Something is wrong if you are seeing this message"
  end


  def clean_summary(summary)
    rv = summary.strip
    rv = rv[1..-1]
    rv = rv.chop
  end

end
