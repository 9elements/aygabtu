module Aygabtu
  module Scope
    module Named
      def named(name)
        raise "nesting/chaining named in/after named makes no sense" if @data[:name]

        new_data = @data.dup.merge(name: name.to_s)
        self.class.new(new_data)
      end

      def matches_route?(route)
        if @data[:name]
          route.name == @data[:name]
        else
          true
        end && super
      end

      def self.factory_method
        :named
      end
    end
  end
end
