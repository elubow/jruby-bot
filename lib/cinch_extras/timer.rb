# @example
# timer 5, method: :some_method
# def some_method
# Channel("#dominikh").send(Time.now.to_s)
# end
module Cinch
  module Plugin
    module ClassMethods
      # @api private
      Timer = Struct.new(:interval, :method, :threaded)
      # @param [Number] interval Interval in seconds
      # @option options [Symbol] :method (:timer) Method to call
      # @option options [Boolean] :threaded (true) Call method in a thread?
      # @return [void]
      def timer(interval, options = {})
        options = {:method => :timer, :threaded => true}.merge(options)
        @__cinch_timers ||= []
        @__cinch_timers << Timer.new(interval, options[:method], options[:threaded])
      end

      register_with_bot = self.instance_method(:__register_with_bot)
      define_method(:__register_with_bot) do |bot, instance|
        register_with_bot.bind(self).call(bot, instance)

        (@__cinch_timers || []).each do |timer|
          bot.debug "[plugin] #{__plugin_name}: Registering timer with interval `#{timer.interval}` for method `#{timer.method}`"
          bot.on :connect do
            Thread.new do
              loop do
                if instance.respond_to?(timer.method)
                  l = lambda {
                    begin
                      instance.__send__(timer.method)
                    rescue => e
                      bot.logger.log_exception(e)
                    end
                  }

                  if timer.threaded
                    Thread.new do
                      l.call
                    end
                  else
                    l.call
                  end
                  sleep timer.interval
                end
              end
            end
          end
        end
      end
    end
  end
end

