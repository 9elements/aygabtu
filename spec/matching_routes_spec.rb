require 'rails_application_helper'

require 'aygabtu/rspec'

require 'json'

require 'support/identifies_routes'

RSpec.configure do |rspec|
  rspec.register_ordering(:honors_final) do |items|
    final, nonfinal = items.partition { |item| item.metadata[:final] }
    [*nonfinal.shuffle, *final]
  end
end

Rails.application.routes.draw do
  extend IdentifiesRoutes

  get 'bogus', identified_by(:controller_route).merge(to: 'controller_a#bogus')

  namespace "namespace" do
    get 'bogus', identified_by(:namespaced_controller_route).merge(to: 'controller_a#bogus')
  end
end

describe "aygabtu scopes and their matching routes", bundled: true, order: :honors_final do
  # make routes_for_scope a hash shared by all example groups below
  def self.routes_for_scope
    return superclass.routes_for_scope if superclass.respond_to?(:routes_for_scope)
    @routes_for_scope ||= {}
  end

  context "wrapping aygabtu declarations for cleanliness only here" do
    include Aygabtu::RSpec.example_group_module

    # routes matched by aygabtu in different contexts are collected here.

    controller(:controller_a) do
      routes_for_scope['controller controller_a'] = aygabtu_matching_routes
    end

    controller('namespace/controller_a') do
      routes_for_scope['controller namespace/controller_a'] = aygabtu_matching_routes
    end
  end

  include IdentifiesRoutes

  describe 'matching routes' do
    # use the :scope metadata to define an example group's routes
    def self.routes
      @routes ||= routes_for_scope.delete(metadata.fetch(:scope)) || raise("bad scope key?")
    end

    # make these routes available to the group's examples
    def routes
      self.class.routes
    end

    describe 'controller scoping' do
      context "scope", scope: 'controller controller_a' do
        it "matches unnamespaced controller" do
          expect(routes).to include(be_identified_by(:controller_route))
        end

        it "matches namespaced controller" do
          expect(routes).to include(be_identified_by(:namespaced_controller_route))
        end
      end

      context "scope", scope: 'controller namespace/controller_a' do
        it "does not match unnamespaced controller" do
          expect(routes).not_to include(be_identified_by(:controller_route))
        end

        it "matches namespaced controller" do
          expect(routes).to include(be_identified_by(:namespaced_controller_route))
        end
      end
    end
  end

  # this example group will be executed last, (see final metadata and declared sorting)
  describe 'test coverage', final: true do
    it "has exhausted all registered scope data" do
      # we cannot make sure this is the last example executed.
      expect(self.class.routes_for_scope).to be_empty
    end
  end

end
