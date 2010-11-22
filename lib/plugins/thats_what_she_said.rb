class ThatsWhatSheSaid
  include Cinch::Plugin

  # Respond to message with the Jira ticket
  prefix "!"
  match /ss (.+)/

  def execute(msg, user)
    msg.reply "#{user}: That's what she said!"
  end

end
