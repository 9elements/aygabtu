module Aygabtu
  module Scope
    module StaticDynamic
      def requiring_anything(boolish = true)
        if boolish
          dynamic_routes
        else
          static_routes
        end
      end

      def static_routes
        static_dynamic(false)
      end

      def dynamic_routes
        static_dynamic(true)
      end

      def matches_route?(route)
        return super if @data[:requiring_anything].nil?

        (@data[:requiring_anything] == route.really_required_keys.present?) && super
      end

      def inspect_data
        super.merge(requiring_anything: @data[:requiring_anything])
      end

      def self.factory_method
        :requiring_anything
      end

      def self.factory_methods
        [ :requiring_anything, :static_routes, :dynamic_routes ]
      end

      private

      def static_dynamic(dynamic)
        self.class.new(@data.merge(requiring_anything: dynamic))
      end
    end
  end
end
