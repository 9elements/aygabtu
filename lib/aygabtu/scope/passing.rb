module Aygabtu
  module Scope
    module Passing
      def passing(pass_data)
        passing = self.pass_data.merge(pass_data)
        new_data = @data.dup.merge(passing: passing)
        self.class.new(new_data)
      end

      def inspect_data
        super.merge(passing: inspected_or_nil(@data[:passing]))
      end

      def self.factory_method
        :passing
      end
    end
  end
end
