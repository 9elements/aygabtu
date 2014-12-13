module Aygabtu
  module Scope
    module Action
      def action(*actions)
        raise "nesting/chaining action scopes makes no sense" if @data[:action]

        new_data = @data.dup.merge(actions: actions.map(&:to_s))
        self.class.new(new_data)
      end

      def matches_route?(route)
        if @data[:actions]
          @data[:actions].include?(route.action)
        else
          true
        end && super
      end

      def segments_split_once
        return super unless Array(@data[:actions]).length > 1

        @data[:actions].map do |action|
          new_data = @data.merge(actions: [action])
          self.class.new(new_data)
        end
      end

      def inspect_data
        return super unless actions = @data[:actions]
        super.merge(action: actions.map(&:inspect).join('; '))
      end

      def self.factory_methods
        [:action]
      end
    end
  end
end
