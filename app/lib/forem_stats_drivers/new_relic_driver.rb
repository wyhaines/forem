module ForemStatsDrivers
  class NewRelicDriver
    extend ::NewRelic::Agent::MethodTracer

    include ActsAsForemStatsDriver

    def gauge(metric_name, metric_value, options = {})
      metric_name = translate_metric_name(metric_name, options)

      puts "gauge(#{metric_name} == #{metric_value}"
      ::NewRelic::Agent.record_metric(metric_name, metric_value)
    end

    def increment(metric_name, options = {})
      metric_name = translate_metric_name(metric_name, options)

      increment_impl(metric_name, 1)
    end

    def count(metric_name, metric_value, options = {})
      metric_name = translate_metric_name(metric_name, options)

      increment_impl(metric_name, metric_value)
    end

    def time(metric_name, options = {}, &blk)
      metric_name = translate_metric_name(metric_name, options)

      self.class.trace_execution_scoped([metric_name]) do
        blk.call
      end
    end

    def translate_metric_name(metric_name, options)
      tags = options[:tags]
      add_tags_to_metric_name(
        new_relic_metric_name(metric_name),
        tags
      )
    end

    def new_relic_metric_name(name)
      "Custom/#{name.gsub(/\.|::/,"/")}"
    end

    def add_tags_to_metric_name(metric_name, tags)
      return metric_name if tags.nil?

      [metric_name, tags.collect do |tag|
        key, value = tag.split(/:/,2)
        "#{key}/#{value}"
      end.join("/")].
      join("/")
    end

    
    private

    def increment_impl(metric_name, amount)
      puts "increment(#{metric_name} == #{amount}"

      ::NewRelic::Agent.increment_metric(metric_name, amount)
    end

  end
end
