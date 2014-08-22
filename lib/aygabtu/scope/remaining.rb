module Aygabtu
  module Scope
    module Remaining
      def remaining
        new_data = @data.dup.merge(remaining: true)
        self.class.new(new_data)
      end

      def matches_route?(route)
        (!@data[:remaining] || !route.touched?) && super
      end

      def inspect_data
        super.merge(remaining: @data[:remaining])
      end

      def self.factory_method
        :remaining
      end
    end
  end
end
