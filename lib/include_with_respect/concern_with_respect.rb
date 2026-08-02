# frozen_string_literal: true

# This is an ActiveSupport::Concern that will make other concerns "include with respect"
# Usage:
#   module MyConcern
#     extend ActiveSupport::Concern
#
#     included do
#       include IncludeWithRespect::ConcernWithRespect
#       include SomeOtherConcern
#     end
#   end
module IncludeWithRespect
  module ConcernWithRespect
    extend ActiveSupport::Concern

    included do
      # Rename standard include to include_without_respect
      define_singleton_method(:include_without_respect, Module.instance_method(:include).bind(base))
      # Rename standard extend to extend_without_respect
      define_singleton_method(:extend_without_respect, Module.instance_method(:extend).bind(base))
    end

    class_methods do
      # Then define a new version of include,
      #   which ultimately calls the original include as include_without_respect
      def include(module1, *smth)
        IncludeWithRespect.include_with_respect(self, module1, *smth)
      end

      # Then define a new version of extend,
      #   which ultimately calls the original extend as extend_without_respect
      def extend(module1, *smth)
        IncludeWithRespect.extend_with_respect(self, module1, *smth)
      end
    end
  end
end
