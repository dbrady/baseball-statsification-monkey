# Run `COVERAGE=true bundle exec rspec` to turn on coverage
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require 'debugger'
