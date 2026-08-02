# frozen_string_literal: true

RSpec.describe IncludeWithRespect::ModuleWithRespect do
  include_context "my context"

  describe "using with class" do
    subject { MyClassWithRespect.new.foo }

    it "does not raise" do
      block_is_expected.not_to raise_error
    end

    it "properly includes" do
      output = capture(:stdout) { subject }
      logs = ["bar"]
      expect(output).to include(*logs)
    end
  end
end
