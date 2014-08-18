require_relative 'point_of_call'

module Aygabtu
  class Generator
    def initialize(scope, example_group)
      @scope, @example_group = scope, example_group
    end

    generator_methods = [
      :pending_example,
      :pending_no_match_failing_example,
      :example
    ]
    generator_methods.each do |method|
      define_method("generate_#{method}") do |*args|
        code = send(method, *args)
        @example_group.instance_eval(code, *PointOfCall.file_and_line_at_point_of_call)
      end
    end

    private

    def example(route, pass_data)
      visit_path = route.format(pass_data)

      # it is an error to pass too few data, catch where?
      "it(#{route.example_message.inspect}) { visit(#{visit_path.inspect}); aygabtu_assertions }"
    end

    def pending_example(route, reason)
      "it(#{route.example_message.inspect}) { pending #{reason.to_s.inspect} }"
    end

    def pending_no_match_failing_example
      error_message = "No matching route to pend, diagnostics: #{@scope.inspect}"

      "it('is treated as an error by aygabtu when pending and no route matches') { raise #{error_message.inspect} }"
    end
  end
end
