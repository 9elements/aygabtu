require_relative 'route_wrapper'
require_relative 'generator'

module Aygabtu
  class Handle

    def routes
      @routes ||= Rails.application.routes.set.map do |journey_route|
        RouteWrapper.new(journey_route)
      end.select(&:get?)
    end

    def self.actions
      [:pend, :ignore]
    end

    def pend(scope, example_group, reason)
      generator = Generator.new(scope, example_group)

      each_route(scope) do |route|
        generator.generate_pending_example(route, reason)
      end or generator.generate_pending_no_match_failing_example
    end

    def pass(scope, example_group, *args)

    end

    def ignore(*)
    end

    private

    def each_route(scope)
      match = false
      routes.each do |route|
        if scope.matches_route?(route)
          match = true
          yield route
        end
      end

      match
    end
  end
end