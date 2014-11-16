require 'shellwords'
require 'json'
require 'pathname'

require 'bundler'

require 'support/invokes_rspec'

#require 'pry'
#require 'pry-byebug'

describe "behaviour under different gem versions" do
  shared_examples_for "integration-testing aygabtu" do
    include InvokesRspec

    it "passes RouteWrapper tests" do
      expect(rspec_result('spec/lib/route_wrapper_spec.rb')).to contain_only_passed_examples
    end

    it "passes matching routes tests" do
      expect(rspec_result('spec/matching_routes_spec.rb')).to contain_only_passed_examples
    end

    it "passes example anatomy tests" do
      expect(rspec_result('spec/example_spec.rb')).to contain_only_passed_examples
    end

    describe "failures for certain misconfigurations" do
      it "generates failing examples" do
        examples = convert_examples(rspec_result('spec/no_match_failures_spec.rb'))

        expect(examples.select(&:group_passing?)).to all(be_passed)
        expect(examples.select(&:group_pending?)).to all(be_pending)
        expect(examples.select(&:group_failing?)).to all(be_failed)
        # sanity check
        expect(examples.select(&:group_failing?).count).to be == 3

        # aygabtu actions within this example group must not generate any examples
        expect(examples).not_to include(be_group_no_example)

        expect(
          examples.select(&:group_partly_failing?).group_by(&:line_number).values
        ).to all(
          include(be_passed).and include(be_failed) # <3 <3 <3
        )

        # @TODO assertions for passing multiple actions to same route
        # needs changing some things before...
      end

      Example = Struct.new(:full_description, :line_number, :status) do
        def passed?
          status == :passed
        end

        def pending?
          status == :pending
        end

        def failed?
          status == :failed
        end

        def group_passing?
          enclosing_group == :passing
        end

        def group_pending?
          enclosing_group == :pending
        end

        def group_failing?
          enclosing_group == :failing
        end

        def group_partly_failing?
          enclosing_group == :partial
        end

        def group_no_example?
          enclosing_group == :no_example
        end

        private

        def enclosing_group
          case full_description
          when /\bEXAMPLE PASSING\b/
            :passing
          when /\bEXAMPLE PENDING\b/
            :pending
          when /\bEXAMPLE FAILING\b/
            :failing
          when /\bEXAMPLES PARTLY FAILING\b/
            :partial
          when /\bNO EXAMPLE\b/
            :no_example
          else
            raise "unrecognized enclosing example group for example #{inspect}"
          end
        end
      end

      def convert_examples(result)
        result['examples'].map do |raw|
          Example.new(
            raw['full_description'],
            raw['line_number'],
            raw['status'].to_sym
          )
        end
      end
    end

    it "treats nested and chained scopes equally" do
      result = rspec_result('spec/nesting_spec.rb')
      payloads = result['examples'].map do |example|
        example_payload(example)
      end

      expect(payloads).to include('nested')
      expect(payloads).to include('unnested')
    end
  end

  context "the currently only gem combination, more to follow" do
    def gemfile_env
      { 'RAILS_VERSION' => '4.2.0.beta2'}
    end

    include_examples "integration-testing aygabtu"
  end
end

