module Aygabtu
  module Scope
    module StaticDynamic
      def static_routes
        new_static_dynamic_scope(false)
      end

      def dynamic_routes
        new_static_dynamic_scope(true)
      end

      def matches_route?(route)
        return super if @data[:dynamic].nil?

        (@data[:dynamic] == route.really_required_keys.present?) && super
      end

      def inspect_data
        super.merge(dynamic: @data[:dynamic])
      end

      def self.factory_methods
        [ :static_routes, :dynamic_routes ]
      end

      private

      def new_static_dynamic_scope(dynamic)
        self.class.new(@data.merge(dynamic: dynamic))
      end
    end
  end
end
