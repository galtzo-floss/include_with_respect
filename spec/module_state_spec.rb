# frozen_string_literal: true

RSpec.describe "Why is this gem important?" do
  describe "a module with state" do
    subject do
      my_class.send(:include, my_module)
      my_class.send(:include, my_module)
      my_class.send(:include, my_module)
      my_class.send(:include, my_module)
    end

    let(:my_class) do
      Class.new do
        class << self
          attr_accessor :thing
        end
        self.thing = 0
      end
    end
    let(:my_module) do
      Module.new do
        def self.included(base)
          base.thing += 1
        end
      end
    end

    it "has a compound state which you might want to prevent" do
      block_is_expected.to change(my_class, :thing).from(0).to(4)
    end
  end
end
