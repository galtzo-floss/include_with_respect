# frozen_string_literal: true

require "anonymous_loader"
RSpec.describe IncludeWithRespect::Version do
  it "executes the version file for coverage without redefining constants" do
    path = File.expand_path("../../lib/include_with_respect/version.rb", __dir__)
    anonymous_namespace = AnonymousLoader.load(files: path)

    expect(anonymous_namespace::IncludeWithRespect::Version::VERSION).to eq(described_class::VERSION)
  end
end
