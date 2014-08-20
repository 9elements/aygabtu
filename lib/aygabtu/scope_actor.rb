require_relative 'generator'

module Aygabtu
  class ScopeActor
    def initialize(scope, routes, example_group)
      @scope, @routes, @example_group = scope, routes, example_group
    end

    def self.actions
      [:pass, :pend, :ignore]
    end

    def pass(pass_data)
      pass_data = @scope.pass_data.merge(pass_data)

      each_route do |route|
        route.touch!
        generator.generate_example(route, pass_data)
      end or generator.generate_pending_no_match_failing_example # @TODO
    end

    def ignore(reason)
      raise "Reason for ignoring must be a string" unless reason.is_a?(String)

      each_route(&:touch!)
    end

    def pend(reason)
      each_route do |route|
        route.touch!
        generator.generate_pending_example(route, reason)
      end or generator.generate_pending_no_match_failing_example
    end

    private

    def generator
      @generator ||= Generator.new(@scope, @example_group)
    end

    def each_route
      match = false
      @routes.each do |route|
        if @scope.matches_route?(route)
          match = true
          yield route
        end
      end

      match
    end
  end
end
