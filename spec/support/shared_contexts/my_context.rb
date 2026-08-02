# frozen_string_literal: true

RSpec.shared_context "my context" do
  let(:my_class) do
    Class.new do
      include MyModule
    end
  end
  let(:my_module) do
    Module.new do
      def self.included(base)
        puts "my_module included into #{base}"
        $respect_semaphore << "my_module"
        base.send(:include, MyIncludedModule)
      end
    end
  end
  let(:my_included_module) do
    Module.new do
      def self.included(base)
        puts "my_included_module included into #{base}"
        $respect_semaphore << "my_included_module"
      end

      def foo
        puts "bar"
      end
    end
  end
  let(:my_class_with_respect) do
    Class.new do
      include IncludeWithRespect::ModuleWithRespect
      include MyModule
    end
  end

  before do
    stub_const("MyIncludedModule", my_included_module)
    stub_const("MyModule", my_module)
    stub_const("MyClass", my_class)
    stub_const("MyClassWithRespect", my_class_with_respect)
  end
end
