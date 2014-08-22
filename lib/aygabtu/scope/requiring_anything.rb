module Aygabtu
  module Scope
    module RequiringAnything
      def requiring_anything(boolish = true)
        self.class.new(@data.merge(requiring_anything: !!boolish))
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
    end
  end
end
