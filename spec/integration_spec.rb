require 'shellwords'
require 'json'
require 'pathname'

require 'bundler'

require 'support/invokes_rspec'

#require 'pry'
#require 'pry-byebug'

describe "foo" do
  context "foo" do
    include InvokesRspec

    def gemfile_env
      { 'RAILS_VERSION' => '4.2.0.beta2'}
    end

    it "passes RouteWrapper tests" do
      expect(rspec_result('spec/lib/route_wrapper_spec.rb')).to contain_only_passed_examples
    end

    it "passes matching routes tests" do
      expect(rspec_result('spec/matching_routes_spec.rb')).to contain_only_passed_examples
    end
  end
end

