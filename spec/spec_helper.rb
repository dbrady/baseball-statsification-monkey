# spec_helper.rb

# custom matcher for StringIO having been written to
# DANGER: THIS MATCHER REWINDS, AND THUS *ALTERS* THE BUFFER
# ONCE YOU CALL THIS, PLEASE DO NOT CONTINUE WRITING TO THE BUFFER
RSpec::Matchers.define :have_been_written_to_with do |expected|
  match do |actual|
    actual.rewind
    actual.read.include? expected
  end

  failure_message_for_should do |actual|
    actual.rewind
    "expected that buffer #{actual.read.inspect} would contain #{expected.inspect}"
  end

  failure_message_for_should_not do |actual|
    actual.rewind
    "expected that buffer #{actual.read.inspect} would not contain #{expected.inspect}"
  end

  description do
    "have been written to with #{expected.inspect}"
  end

end
