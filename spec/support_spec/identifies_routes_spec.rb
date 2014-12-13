require 'rails_application_helper'

require 'aygabtu/rspec'

require 'support/identifies_routes'
require 'support/aygabtu_sees_routes'
require 'support/matcher_shims'

describe "test mechanism for identifying routes independently of controller, name and action" do
  extend AygabtuSeesRoutes

  include Aygabtu::RSpec.example_group_module

  aygabtu_sees_routes do
    get 'bogus', identified_by(:an_identifier).merge(to: 'bogus#action1')
    get 'bogus', identified_by(:another_identifier).merge(to: 'bogus#action2')
  end

  include IdentifiesRoutes
  include MatcherShims

  describe "route_identified_by" do
    it "returns the correct route" do
      expect(route_identified_by(:an_identifier).action).to be == 'action1'
      expect(route_identified_by(:another_identifier).action).to be == 'action2'
    end
  end

  describe "be_identified_by" do
    it "works inside our matcher" do
      expect(all_routes).to contain_exactly(
        be_identified_by(:an_identifier),
        be_identified_by(:another_identifier)
      )

      # assert difference is really taken into account
      expect(all_routes).not_to contain_exactly(
        be_identified_by(:an_identifier),
        be_identified_by(:an_identifier)
      )
    end
  end

  # interface expected by IdentifiesRoutes
  def all_routes
    self.class.aygabtu_matching_routes
  end
end

