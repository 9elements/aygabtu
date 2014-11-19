module Aygabtu
  module Scope
    module VisitingWith
      def visiting_with(visiting_data)
        visiting_data = self.visiting_data.merge(visiting_data)
        new_data = @data.dup.merge(visiting_data: visiting_data)
        self.class.new(new_data)
      end

      def inspect_data
        super.merge(visiting_data: inspected_or_nil(@data[:visiting_data]))
      end

      def self.factory_method
        :visiting_with
      end
    end
  end
end
