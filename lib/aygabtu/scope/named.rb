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

      def segments_split_once
        return super unless Array(@data[:names]).length > 1

        @data[:names].map do |name|
          new_data = @data.merge(names: [name])
          self.class.new(new_data)
        end
      end

      def inspect_data
        return super unless names = @data[:names]
        super.merge(name: names.map(&:inspect).join('; '))
      end

      def self.factory_methods
        [:named]
      end
    end
  end
end
