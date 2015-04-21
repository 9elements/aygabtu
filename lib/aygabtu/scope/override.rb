module Aygabtu
  module Scope

    # ATTENTION
    #
    # This is a *temporary* feature to work around certain bugs related
    # to traversing remaining routes multiple times
    #
    # See: https://github.com/9elements/aygabtu/issues/5

    module Override

      def override(aygabtu_routes)
        new_data = @data.dup.merge(overrides: aygabtu_routes)
        self.class.new(new_data)
      end

      module OverrideBehavior
        def matches_route?(route)
          return super unless @data.key?(:overrides)

          @data[:overrides].include?(route)
        end
      end

      def inspect_data
        return super unless overrides = @data[:overrides]
        super.merge(override: overrides.map(&:inspect).join('; '))
      end

      def self.factory_methods
        [:override]
      end

      def self.override_behavior
        OverrideBehavior
      end
    end
  end
end
