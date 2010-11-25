class SendHelp
  include Cinch::Plugin

  # Respond to the user with a help menu
  prefix "!"
  match "help"

  # Send the help message to a user
  def execute(msg)
    username = User(msg.user)
    username.send "To see this message:"
    username.send "  !help"

    username.send "To see a jira ticket, type:"
    username.send "  !jira <ticket>"
    username.send "  !jira JRUBY-5182"

    username.send "\"That's what she said\" a user:"
    username.send "  !ss <nick>"
    username.send "Or \"That's what she said\" the channel:"
    username.send "  !ss"
  end

end
