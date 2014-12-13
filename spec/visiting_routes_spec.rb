require 'rails_application_helper'

require 'aygabtu/rspec'

require 'support/aygabtu_sees_routes'
require 'support/identifies_routes'

describe "aygabtu scopes and their matching routes", type: :feature do
  extend AygabtuSeesRoutes

  include Aygabtu::RSpec.example_group_module

  aygabtu_sees_routes do
    get 'bogus', to: 'bogus#route_without'
    get 'bogus/:segment1', to: 'bogus#route_with'
    get 'bogus/:segment1/:segment2', to: 'bogus#route_with_two'
  end

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

  action(:route_without).visit
  context "with an additional parameter" do
    def assert_path(path)
      expect(URI.parse(path).query).to be == "additional_parameter=bogus"
    end

    action(:route_without).visit_with(additional_parameter: "bogus")
  end

  action(:route_with).visit_with(segment1: "bogus")
  action(:route_with).visiting_with(segment1: "bogus") do
    visit
  end

  action(:route_with) do
    visit_with(segment1: "bogus")
  end

  action(:route_with_two).visit_with(segment1: "bogus", segment2: "bogus")
  action(:route_with_two).visiting_with(segment1: "bogus") do
    visit_with(segment2: "bogus")
  end
end

