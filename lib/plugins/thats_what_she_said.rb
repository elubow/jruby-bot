class ThatsWhatSheSaid
  include Cinch::Plugin

  # Respond to message with the Jira ticket
  prefix "!"
  match /ss ?(.+)?/

  def execute(msg, user)
    if user.class.is_a?(NilClass)
      msg.reply "That's what she said!"
    else
      msg.reply "#{user}: That's what she said!"
    end
  end

end
