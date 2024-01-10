# frozen_string_literal: true

RSpec::Matchers.define :have_configuration_option do |option|
  match do |configuration|
    configuration.respond_to?(option) &&
      configuration.respond_to?(:"#{option}=") &&
      (@default.nil? || configuration.public_send(option) == @default)
  end

  chain :with_default do |default|
    @default = default
  end

  failure_message do |_configuration|
    description =  "expected configuration to have #{option.inspect} option"
    description << " with a default of #{@default.inspect}" unless @default.nil?
    description
  end
end
