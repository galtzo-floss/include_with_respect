# frozen_string_literal: true

RSpec.describe IncludeWithRespect do
  include_context 'my context'

  it 'has a version number' do
    expect(IncludeWithRespect::VERSION).not_to be nil
  end

  describe 'Error' do
    let(:message) { 'This is a very bad error' }
    subject { raise IncludeWithRespect::Error, message }
    it 'can be raised' do
      block_is_expected.to raise_error(IncludeWithRespect::Error, message)
    end
  end

  describe '#include_with_respect' do
    let(:local_class) do
      Class.new do
        class << self
          alias_method :include_without_respect, :include
        end
      end
    end
    let(:local_module) do
      Module.new do
        def self.included(base)
          puts "my_included_module included into #{base}"
          $respect_semaphore << 'local_module'
        end
        def foo
          puts "duduk #{$respect_semaphore}"
        end
      end
    end
    let(:level) { :warning }
    before do
      IncludeWithRespect.configuration.level = level
      expect(IncludeWithRespect.configuration.level).to eq([level])
      LocalClass = local_class
      LocalModule = local_module
    end
    after do
      Object.send(:remove_const, :LocalModule)
      Object.send(:remove_const, :LocalClass)
      IncludeWithRespect.configuration.level = :warning
    end

    context 'without collision' do
      subject { described_class.include_with_respect(LocalClass, LocalModule) }
      it 'does not raise' do
        block_is_expected.not_to raise_error
      end

      it 'properly includes' do
        subject

        output = capture(:stdout) { LocalClass.new.foo }
        logs = ['duduk']
        expect(output).to include(*logs)
      end
    end

    # Test that `Module#include` override is not global
    context 'with collision without respect' do
      subject { LocalClass.send(:include, LocalModule) }
      let(:local_class) do
        Class.new do
          include MyIncludedModule
          def foo
            puts "duduk #{$respect_semaphore}"
            super
          end
        end
      end
      let(:local_module) do
        Module.new do
          def self.included(base)
            puts "local_module included into #{base}"
            $respect_semaphore << 'local_module'
            base.send(:include, MyIncludedModule)
          end
        end
      end

      it 'does not raise' do
        block_is_expected.not_to raise_error
      end

      it 'properly includes' do
        subject

        output = capture(:stdout) { LocalClass.new.foo }
        logs = ['duduk', 'bar']
        expect(output).to include(*logs)
      end
    end

    context 'with collision with respect' do
      let(:message) { 'MyIncludedModule already included in LocalClass' }
      let(:local_class) do
        Class.new(MyClassWithRespect) do
          def foo
            puts "duduk #{$respect_semaphore}"
            super
          end
        end
      end
      let(:local_module) do
        Module.new do
          def self.included(base)
            puts "my_included_module included into #{base}"
            $respect_semaphore << 'local_module'
            base.send(:include, MyIncludedModule)
          end
        end
      end
      subject do
        LocalClass.send(:include, LocalModule)
        LocalClass.new.foo
      end

      context 'with level = :warning' do
        let(:level) { :warning }
        it 'prints warning to STDOUT' do
          output = capture(:stdout) { subject }
          logs = [message]
          expect(output).to include(*logs)
        end
        it 'does the include' do
          output = capture(:stdout) { subject }
          logs = ['duduk', 'bar']
          expect(output).to include(*logs)
        end
      end
      context 'with level = :skip' do
        let(:level) { :skip }
        it 'does not print warning to STDOUT' do
          output = capture(:stdout) { subject }
          logs = [message]
          expect(output).not_to include(*logs)
        end
        it 'does the include' do
          output = capture(:stdout) { subject }
          logs = ['duduk', 'bar']
          expect(output).to include(*logs)
        end
      end
      context 'with level = :error' do
        let(:level) { :error }
        it 'raises error' do
          expect(IncludeWithRespect.configuration.level).to eq([:error])
          block_is_expected.to raise_error(IncludeWithRespect::Error, message)
        end
      end
      context 'with level = :silent' do
        let(:level) { :silent }
        it 'does not print warning to STDOUT' do
          output = capture(:stdout) { LocalClass.new.foo }
          logs = [message]
          expect(output).not_to include(*logs)
        end
        it 'does not raise error' do
          block_is_expected.not_to raise_error
        end
        it 'does the include' do
          output = capture(:stdout) { LocalClass.new.foo }
          logs = ['duduk', 'bar']
          expect(output).to include(*logs)
        end
      end

      context 'with nesting' do
        let(:message) { 'MyIncludedModule already included in LocalClass' } # MyModule from parent class!
        let(:local_class) do
          Class.new(MyClassWithRespect) do
            include MyModule
            def foo
              puts "duduk #{$respect_semaphore}"
              super
            end
          end
        end
        let(:local_module) do
          Module.new do
            def self.included(base)
              puts "local_module included into #{base}"
              $respect_semaphore << 'local_module'
              base.send(:include, MyIncludedModule)
            end
          end
        end

        context 'with level = :warning' do
          let(:level) { :warning }
          it 'prints warning to STDOUT' do
            output = capture(:stdout) { subject }
            logs = [message]
            expect(output).to include(*logs)
          end
          it 'does the include' do
            output = capture(:stdout) { subject }
            logs = ['duduk', 'bar']
            expect(output).to include(*logs)
          end
        end
        context 'with level = :skip' do
          let(:level) { :skip }
          it 'does not print warning to STDOUT' do
            output = capture(:stdout) { subject }
            logs = [message]
            expect(output).not_to include(*logs)
          end
          it 'does the include' do
            output = capture(:stdout) { subject }
            logs = ['duduk', 'bar']
            expect(output).to include(*logs)
          end
        end
        # Can't test error with nested repeated include because the class declaration will raise early @ before(:each)
        # context 'with level = :error' do
        #   let(:level) { :error }
        #   it 'raises error' do
        #     block_is_expected.to raise_error(IncludeWithRespect::Error, message)
        #   end
        # end
        context 'with level = :silent' do
          let(:level) { :silent }
          it 'does not print warning to STDOUT' do
            output = capture(:stdout) { subject }
            logs = [message]
            expect(output).not_to include(*logs)
          end
          it 'does not raise error' do
            block_is_expected.not_to raise_error
          end
          it 'does the include' do
            output = capture(:stdout) { subject }
            logs = ['duduk', 'bar']
            expect(output).to include(*logs)
          end
        end
      end
    end
  end
end
