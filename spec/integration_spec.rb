require 'support/invokes_rspec'

describe "behaviour under different gem versions" do
  shared_examples_for "integration-testing aygabtu" do
    include InvokesRspec

    it "passes RouteWrapper tests" do
      expect(rspec_result('spec/lib/route_wrapper_spec.rb').examples).to all(be_passed)
    end

    it "passes matching routes tests" do
      expect(rspec_result('spec/matching_routes_spec.rb').examples).to all(be_passed)
    end

    it "passes example anatomy tests" do
      expect(rspec_result('spec/example_spec.rb').examples).to all(be_passed)
    end

    it "passes visiting with parameters tests" do
      expect(rspec_result('spec/visiting_routes_spec.rb').examples).to all(be_passed)
    end
  end

  context "the currently only gem combination, more to follow" do
    def gemfile_env
      { 'RAILS_VERSION' => '4.2.0.beta2'}
    end

    include_examples "integration-testing aygabtu"
  end
end

