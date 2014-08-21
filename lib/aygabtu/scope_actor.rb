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
      each_empty_scope_segment do |scope, generator|
        generator.generate_no_match_failing_example(:pass)
      end

      each_scope_segment_and_route do |scope, generator, route|
        pass_data = @scope.pass_data.merge(pass_data)

        route.touch!
        generator.generate_example(route, pass_data)
      end
    end

    def ignore(reason)
      raise "Reason for ignoring must be a string" unless reason.is_a?(String)

      each_empty_scope_segment do |scope, generator|
        generator.generate_no_match_failing_example(:ignore)
      end

      each_scope_segment_and_route do |scope, generator, route|
        route.touch!
      end
    end

    def pend(reason)
      each_empty_scope_segment do |scope, generator|
        generator.generate_no_match_failing_example(:pend)
      end

      each_scope_segment_and_route do |scope, generator, route|
        route.touch!
        generator.generate_pending_example(route, reason)
      end
    end

    private

    def each_scope_segment_and_route
      segments_generators_routes.each do |segment, generator, routes|
        routes.each { |route| yield segment, generator, route }
      end
    end

    def each_empty_scope_segment
      segments_generators_routes.each do |segment, generator, routes|
        next unless routes.empty?

        yield segment, generator
      end
    end

    def segments_generators_routes
      @segments_and_generators ||= @scope.segments.map do |segment|
        generator = Generator.new(segment, @example_group)
        routes = @routes.select { |route| segment.matches_route?(route) }

        [segment, generator, routes]
      end
    end
  end
end
