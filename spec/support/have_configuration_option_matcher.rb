RSpec::Matchers.define :have_configuration_option do |option|
  match do |configuration|
    configuration.should respond_to(option)
    configuration.__send__(option).should == @default if defined?(@default)
    configuration.__send__(:"#{option}=", "value")
    configuration.__send__(option).should == "value"
  end

  chain :with_default do |default|
    @default = default
  end

  failure_message do
    description  = "expected #{subject} to have"
    description << " configuration option #{option.inspect}"
    description << " with a default of #{@default.inspect}" if defined?(@default)
    description
  end
end
