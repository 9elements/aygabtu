require 'rails_application_helper'

require 'aygabtu/rspec'

require 'support/identifies_routes'

Rails.application.routes.draw do
  extend IdentifiesRoutes

  get 'bogus', to: 'bogus#route_without'
  get 'bogus/:segment1', to: 'bogus#route_with'
  get 'bogus/:segment1/:segment2', to: 'bogus#route_with_two'
end

describe "aygabtu scopes and their matching routes", bundled: true, type: :feature do
  include Aygabtu::RSpec.example_group_module

  def assert_path(path)
    # The fact that the path has already been formed means
    # that the router accepted the route arguments, so no segment
    # can be missing.
    # We just asssert here that no excess parameters have been passed.
    expect(path).not_to include('?')
  end

  def visit(path)
    assert_path path
  end

  def aygabtu_assertions
  end

  action(:route_without).pass
  context "with an additional parameter" do
    def assert_path(path)
      expect(URI.parse(path).query).to be == "additional_parameter=bogus"
    end

    action(:route_without).pass(additional_parameter: "bogus")
  end

  action(:route_with).pass(segment1: "bogus")

  action(:route_with) do
    pass(segment1: "bogus")
  end

  action(:route_with_two).pass(segment1: "bogus", segment2: "bogus")
  action(:route_with_two).visiting_with(segment1: "bogus") do
    pass(segment2: "bogus")
  end
end

