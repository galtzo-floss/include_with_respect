module ActiveSupport
  module Concern
    def self.included(base)
      base.send(:include, IncludeWithRespect::ModuleWithRespect)
    end
  end
end
