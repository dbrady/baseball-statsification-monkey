# Run `COVERAGE=true bundle exec rspec` to turn on coverage
if ENV['COVERAGE']
  require 'simplecov'
  formatters = [SimpleCov::Formatter::HTMLFormatter]
  begin
    require 'metric_fu/logger' # workaround mf_log undefined
    require 'metric_fu/metrics/rcov/simplecov_formatter'
    formatters << SimpleCov::Formatter::MetricFu
  rescue LoadError
    # not running metric_fu formatter
  end
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    *formatters
  ]
  SimpleCov.start
end

require 'debugger'
