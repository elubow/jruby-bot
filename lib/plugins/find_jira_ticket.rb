class FindJiraTicket
  include Cinch::Plugin

  # Respond to message with the Jira ticket
  prefix "!"
  match /jira (.+)/

  def execute(msg, query)
    unless valid_ticket?(query)
      msg.reply "I only use Jira to research jruby tickets"
      return
    end

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

  def valid_ticket?(query)
    rv = false
    rv = true if query =~ /jruby.*/i
    rv
  end

end
