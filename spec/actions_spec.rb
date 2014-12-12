require 'support/invokes_rspec'
require 'support/contain_exactly_shim'

describe "actions" do
  include InvokesRspec
  include ContainExactlyShim

  def rspec_file_preamble
    %{
require 'rails_application_helper'

require 'aygabtu/rspec'

Rails.application.routes.draw do
  get 'bogus', to: 'bogus#visited', as: :named
  get 'bogus', to: 'bogus#pended'
  get 'bogus', to: 'bogus#ignored'

  get 'bogus', to: 'bogus#doubly_pended'
  get 'bogus', to: 'bogus#doubly_ignored'
  get 'bogus', to: 'bogus#pended_and_ignored'
  get 'bogus', to: 'bogus#visited_and_ignored'
  get 'bogus', to: 'bogus#visited_and_pended'
end
    }
  end

  def rspec_file_content
    rspec_file_preamble + get_rspec_file_main_content
  end

  def get_rspec_file_main_content
    start_line = method(:rspec_file_main_content).source_location[1]
    File.open(__FILE__) do |file|
      lines = file.each_line.to_a.drop(start_line - 1)
      whitespace = lines.first[/^\s*/]
      slices = lines.slice_before do |line|
        line.start_with?(whitespace + 'end')
      end

      # return only the method body
      slices.first.drop(1).join('')
    end
  end

  context "when visit is used and a route matches" do
    def rspec_file_main_content
      describe "aygabtu examples" do
        include Aygabtu::RSpec.example_group_module

        def visit(*)
        end

        def aygabtu_assertions
        end

        action(:visited).visit
        named(:named).visit
      end
    end

    it "generates examples being exercised" do
      expect(rspec_result.examples).to \
        contain_exactly(be_passed, be_passed)
    end
  end

  context "when pend is used and a route matches" do
    def rspec_file_main_content
      describe "aygabtu examples" do
        include Aygabtu::RSpec.example_group_module

        action(:pended).pend "bogus reason"
      end
    end

    it "generates examples which are pending" do
      expect(rspec_result.examples).to \
        contain_exactly(be_pending)
    end
  end

  context "when ignore is used and a route matches" do
    def rspec_file_main_content
      describe "aygabtu examples" do
        include Aygabtu::RSpec.example_group_module

        action(:ignored).ignore "bogus reason"
      end
    end

    it "does not generate examles" do
      expect(rspec_result.examples).to be_empty
    end
  end

  context "when using an action when no route matches" do
    def rspec_file_main_content
      describe "aygabtu examples" do
        include Aygabtu::RSpec.example_group_module

        action(:nonexiting).visit
        action(:nonexiting).pend "bogus reason"
        action(:nonexiting).ignore "bogus reason"
      end
    end

    it "generates failing examples" do
      expect(rspec_result.examples).to \
        contain_exactly(be_failed, be_failed, be_failed)
    end
  end

  context "when passing multiple arguments to a splitting scope, one argument not matching a route" do
    def rspec_file_main_content
      describe "aygabtu examples" do
        include Aygabtu::RSpec.example_group_module

        def visit(*)
        end

        def aygabtu_assertions
        end

        action(:visited, :nonexisting).visit
        named(:named, :nonexisting).visit
      end
    end

    it "generates a failing example besides what the action produces for the other arguments" do
      examples_grouped_by_line = rspec_result.examples.group_by(&:line_number).values

      expect(
        examples_grouped_by_line
      ).to all(
        include(be_passed).and include(be_failed) # <3 <3 <3
      )

      # sanity check
      expect(examples_grouped_by_line.length).to be == 2
    end
  end

  context "when calling pend matching the same route a second time" do
    pending "currently raises an exception at load time"
  end

  context "when calling ignore matching the same route a second time" do
    pending "currently raises an exception at load time"
  end
end

