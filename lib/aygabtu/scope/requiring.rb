module Aygabtu
  module Scope
    module Requiring
      def requiring(*keys)
        new_requiring = [*@data[:requiring], *keys]
        new_data = @data.dup.merge(requiring: new_requiring)
        self.class.new(new_data)
      end

      def matches_route?(route)
        Array(@data[:requiring]).all? do |key|
          route.really_required_keys.include?(key.to_s)
        end && super
      end

      def inspect_data
        return super unless @data[:requiring]
        super.merge(requiring: @data[:requiring].inspect)
      end

      def self.factory_methods
        [:requiring]
      end
    end
  end
end
