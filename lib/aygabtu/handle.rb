require_relative 'route_wrapper'
require_relative 'scope_actor'

module Aygabtu
  class Handle

    def routes
      @routes ||= Rails.application.routes.set.map do |journey_route|
        RouteWrapper.new(journey_route)
      end.select(&:get?).reject(&:internal?)
    end

    def self.actions
      ScopeActor.actions
    end

    def pend(scope, example_group, reason)
      ScopeActor.new(scope, routes, example_group).pend(reason)
    end

    def pass(scope, example_group, pass_data = {})
      ScopeActor.new(scope, routes, example_group).pass(pass_data)
    end

    def ignore(scope, example_group, reason)
      ScopeActor.new(scope, routes, example_group).ignore(reason)
    end
  end
end
