module ConfigurationHelper
  class ConfigurationOption
    def initialize(option)
      @option = option
    end

    def matches?(configuration)
      @configuration = configuration
      @configuration.respond_to?(@option).should == true

      if instance_variables.include?(:@default)
        actual = @configuration.__send__(@option)

        if @default.is_a?(Hash)
          @default.each do |key, value|
            actual[key].should == value
          end
        else
          actual.should == @default
        end
      end

      @configuration.__send__(:"#{@option}=", "value")
      @configuration.__send__(@option).should == "value"
    end

    def with_default(default)
      @default = default

      self
    end

    def failure_message
      description  = "expected #{@configuration} to have"
      description << " configuration option #{@option.inspect}"
      description << " with a default of #{@default.inspect}" if instance_variables.include?("@default")
      description
    end
  end

  def have_configuration_option(option)
    ConfigurationOption.new(option)
  end
end
