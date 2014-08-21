module Aygabtu
  module Scope
    module Named
      def named(*names)
        raise "nesting/chaining named in/after named makes no sense" if @data[:names]

        new_data = @data.dup.merge(names: names.map(&:to_s))
        self.class.new(new_data)
      end

      def matches_route?(route)
        if @data[:names]
          @data[:names].include?(route.name)
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
