require_relative 'point_of_call'

module Aygabtu
  class Generator
    def initialize(scope, example_group)
      @scope, @example_group = scope, example_group
    end

    generator_methods = [
      :pending_example,
      :no_match_failing_example,
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
      # it is an error to pass too few data, catch where?
      statements = [
        "self.aygabtu_path_to_visit = aygabtu_pass_to_route(#{route.object_id}, #{pass_data.inspect})",
        "aygabtu_example_for(aygabtu_path_to_visit)"
      ]
      "it(#{route.example_message.inspect}) { #{statements.join('; ')} }"
    end

    def pending_example(route, reason)
      body = [
        "pending #{reason.to_s.inspect}"
      ]
      if ::RSpec::Core::Version::STRING.split('.').first == '3'
        # RSpec totally changed their mind on pending. We should be using skip here, but apparently skipped
        # examples do not take or report any reason for skipping, and we want the reason to appear
        # at least in the documentation format.
        body << 'raise("rspec_core treats pending examples as failing unless it _would_ fail")'
      end
      "it(#{route.example_message.inspect}) { #{body.join('; ')} }"
    end

    def no_match_failing_example(action)
      error_message = "No matching route (action was: #{action.inspect}, diagnostics: #{@scope.inspect}"

      "it('is treated as an error by aygabtu when no route matches') { raise #{error_message.inspect} }"
    end
  end
end
