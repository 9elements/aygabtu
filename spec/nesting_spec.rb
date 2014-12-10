require 'rails_application_helper'

require 'aygabtu/rspec'

Rails.application.routes.draw do
  scope module: :namespace do
    get 'for_action1', to: 'bogus#action1'
    get 'for_action2', to: 'bogus#action2'
  end
end

describe "nesting and chaining scopes" do
  include Aygabtu::RSpec.example_group_module

  context "asserting the right route is being visited" do
    before do
      @spy = double
      expect(@spy).to receive(:visit).with(be_path_for_this_route)
    end
    attr_reader :spy

    def visit(path)
      spy.visit(path)
    end

    def aygabtu_assertions
    end

    context "visiting one route" do
      def be_path_for_this_route
        include('for_action1')
      end

      namespace(:namespace) do
        action(:action1).visit
      end
    end

    context "visiting another route" do
      def be_path_for_this_route
        include('for_action2')
      end

      namespace(:namespace).action(:action2).visit
    end
  end

  remaining do
    # sanity check.
    it "has covered routes and thus created two examples" do
      expect(self.class.aygabtu_matching_routes).to be_empty
    end
  end
end

