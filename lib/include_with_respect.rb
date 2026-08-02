# frozen_string_literal: true

require "include_with_respect/configuration"

# How to automatically inject into ActiveSupport::Concern,
#   or other module dependency trees?
# Refer to inline documentation in each file.
require "include_with_respect/module_with_respect"
require_relative "include_with_respect/version"

require "include_with_respect/concern_with_respect" if defined?(ActiveSupport)

# [Sometimes] We should respect our ancestors.
#
# ## Raw Usage (see lib/include_with_respect/module_with_respect for the non-intrusive interface)
#
# If you swap `include` for `include_with_respect`, when a module is already among our ancestors does not re-include it.
# Why?
#   Some modules have side effects on the `included` hook which can be problematic if they run more than once.
#   Additionally, including a module multiple times will override the original include,
#     but in a messy way, with potentially dangerous side effects and shared state.
#
module IncludeWithRespect
  class Error < StandardError; end

  def include_with_respect(receiver, module1, *smth)
    skip = receiver.include?(module1) && have_respect("included", receiver, module1, *smth)

    receiver.send(:include_without_respect, module1, *smth) unless skip
  end
  module_function :include_with_respect

  def extend_with_respect(receiver, module1, *smth)
    skip = receiver.singleton_class.include?(module1) && have_respect("extended", receiver, module1, *smth)

    receiver.send(:extend_without_respect, module1, *smth) unless skip
  end
  module_function :extend_with_respect

  # For single statement global config in an initializer
  # e.g. IncludeWithRespect.configuration.level = :error
  def self.configuration
    self.include_with_respect_configuration ||= Configuration.new
  end

  # For global config in an initializer with a block
  def self.configure
    yield(configuration)
  end

  #### CONFIG ####
  class << self
    attr_accessor :include_with_respect_configuration
  end

  private

  def have_respect(action, receiver, module1, *smth)
    message = "#{module1}#{" with #{smth}" if smth.any?} already #{action} in #{receiver}"
    puts "message: #{message}" if configuration.level == [:error]
    configuration.level.any? do |level|
      case level
      when :error
        raise ::IncludeWithRespect::Error, message
      when :warning
        puts message
      when :skip
        true
      else # :silent
        # NOOP
        false
      end
    end
  end
  module_function :have_respect
end
