require_relative 'point_of_call'
require_relative 'route_mark'
require_relative 'generator'

module Aygabtu
  class ScopeActor
    def initialize(scope, example_group)
      @scope, @example_group = scope, example_group
    end

    def self.actions
      [:visit_with, :visit, :pend, :ignore, :covered!]
    end

    def visit_with(visiting_data)
      each_empty_scope_segment do |scope, generator|
        generator.generate_no_match_failing_example(:visit)
      end

      each_scope_segment_and_route do |scope, generator, route|
        visiting_data = @scope.visiting_data.merge(visiting_data)

        mark_route(route, :visit)
        generator.generate_example(route, visiting_data)
      end
    end

    def visit
      visit_with({})
    end

    def ignore(reason)
      raise "Reason for ignoring must be a string" unless reason.is_a?(String)

      each_empty_scope_segment do |scope, generator|
        generator.generate_no_match_failing_example(:ignore)
      end

      each_scope_segment_and_route do |scope, generator, route|
        mark_route(route, :ignore)
      end
    end

    def covered!
      ignore "this is already covered by a non-aygabtu feature"
    end

    def pend(reason)
      each_empty_scope_segment do |scope, generator|
        generator.generate_no_match_failing_example(:pend)
      end

      each_scope_segment_and_route do |scope, generator, route|
        mark_route(route, :pend)
        generator.generate_pending_example(route, reason)
      end
    end

    private

    def mark_route(route, action)
      checkpoint = @example_group.aygabtu_handle.generate_checkpoint
      mark = RouteMark.new(action, PointOfCall.point_of_call, checkpoint)

      conflicting_marks = route.conflicting_marks(mark)
      if conflicting_marks.any?
        conflict_strings = conflicting_marks.map(&:description)
        raise "Action #{action} for #{route.inspect} conflicts with #{conflict_strings.join ", "}"
      else
        route.marks.push mark
      end
    end

    def route_action_valid?(route, action)
      previous_actions_considered = route.marks.keys
      previous_actions_considered.delete(:visit) if action == :visit # creating more than one :visit example per route is allowed
      route.marks.values_at(*previous_actions_considered).all?(&:empty?)
    end

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

        routes = @example_group.aygabtu_matching_routes(segment)

        [segment, generator, routes]
      end
    end
  end
end
