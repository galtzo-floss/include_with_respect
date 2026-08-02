# frozen_string_literal: true

RSpec.describe IncludeWithRespect do
  it "installs ModuleWithRespect into ActiveRecord::Base when the hook is loaded" do
    stub_const("ActiveRecord", Module.new)
    ActiveRecord.const_set(:Base, Class.new)

    load File.expand_path("../../lib/include_with_respect/ext/active_record/base.rb", __dir__)

    expect(ActiveRecord::Base.ancestors).to include(IncludeWithRespect::ModuleWithRespect)
  end

  it "installs ModuleWithRespect when the ActiveSupport::Concern hook is included" do
    stub_const("ActiveSupport", Module.new)
    ActiveSupport.const_set(:Concern, Module.new)
    load File.expand_path("../../lib/include_with_respect/ext/active_support/concern.rb", __dir__)

    host = Class.new
    host.include(ActiveSupport::Concern)

    expect(host.ancestors).to include(IncludeWithRespect::ModuleWithRespect)
  end

  it "applies ConcernWithRespect through the ActiveSupport concern interface" do
    stub_const("ActiveSupport", Module.new)
    ActiveSupport.const_set(:Concern, Module.new do
      def included(*arguments, &block)
        @included_block = block if block
      end

      def class_methods(&block)
        const_set(:ClassMethods, Module.new(&block))
      end

      def apply_to(base)
        base.extend(const_get(:ClassMethods))
        base.define_singleton_method(:base) { self }
        base.class_exec(&@included_block)
      end
    end)
    load File.expand_path("../../lib/include_with_respect/concern_with_respect.rb", __dir__)

    host = Class.new
    described_class::ConcernWithRespect.apply_to(host)
    repeated = Module.new
    host.include(repeated)
    host.extend(repeated)
    begin
      described_class.configuration.level = :skip

      expect { host.include(repeated) }.not_to raise_error
      expect { host.extend(repeated) }.not_to raise_error
    ensure
      described_class.configuration.level = :warning
    end
  end
end
