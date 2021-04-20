class ForemStatsDriver
  def initialize(*_args)
    @driver = select_driver.new
  end

  # All drivers should implement the following methods with
  # the following call signatures
  #
  # count(metric_name, metric_value, options)
  # increment(metric_name, options)
  # time(metric_name, options, &blk)
  # gauge(metric_name, metric_value, options)

  delegate(:count, :increment, :time, :gauge, to: :@driver)

  private

  def select_driver(driver = nil)
    if ENV["NEW_RELIC_LICENSE_KEY"] ||
      Rails.application.config.respond_to?(:newrelic) ||
      driver == :newrelic
      ForemStatsDrivers::NewRelicDriver
    else
      ForemStatsDrivers::DatadogDriver
    end
  end
end
