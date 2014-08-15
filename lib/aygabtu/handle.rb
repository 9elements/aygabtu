require_relative 'route_wrapper'
require_relative 'point_of_call'

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
      code_snippets = []

      generate_scoped_routes_code(scope, example_group) do |route|
        "it(#{route.example_message.inspect}) { pending #{reason.to_s.inspect} }"
      end or generate_in_example_group(example_group) do
        error_message = "No matching route to pend, diagnostics: #{scope.inspect}"

        "it('is treated as an error by aygabtu when pending and no route matches') { raise #{error_message.inspect} }"
      end

      example_group.instance_eval(code_snippets.join('; '), *PointOfCall.file_and_line_at_point_of_call)
    end

    def ignore(*)
    end

    private

    def generate_scoped_routes_code(scope, example_group)
      codes = filtered_routes(scope).map { |route| yield route }
      unless codes.empty?
        generate_in_example_group(example_group, codes.join('; '))
        true
      end
    end

    def generate_in_example_group(example_group, code = nil)
      code ||= yield
      example_group.instance_eval(code, *PointOfCall.file_and_line_at_point_of_call)
    end

    def filtered_routes(scope)
      routes.select do |route|
        scope.matches_route?(route)
      end
    end
  end
end
