# frozen_string_literal: true

module IncludeWithRespect
  class Configuration
    VALID_LEVELS = [:warning, :error, :skip, :silent]
    attr_reader :level

    def initialize(**options)
      self.level = options[:level] || :warning
      validate
    end

    def level=(value)
      @level = Array(value)
    end

    def validate
      unexpected = (level - VALID_LEVELS)
      return unless unexpected.any?

      raise ::IncludeWithRespect::Error, "Unexpected configuration value(s) for level: #{unexpected}"
    end
  end
end
