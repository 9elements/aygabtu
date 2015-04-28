module Aygabtu
  module Scope
    module Remaining
      def remaining_at(checkpoint)
        new_data = @data.dup.merge(remaining_at: checkpoint)
        self.class.new(new_data)
      end

      def matches_route?(route)
        return super unless @data.key?(:remaining_at)
        at_checkpoint = @data[:remaining_at]
        route_touched = route.marks.any? { |mark| mark.checkpoint <= at_checkpoint }
        !route_touched && super
      end

      def inspect_data
        return super unless @data.key?(:remaining_at)
        super.merge(remaining_at: "CP #{@data[:remaining_at]}")
      end

      def self.factory_methods
        [:remaining_at]
      end
    end
  end
end
