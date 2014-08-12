module Aygabtu
  module Scope
    module Namespace
      def namespace(name)
        new_data = @data.dup
        new_data[:namespace] = [@data[:namespace], name]
        self.class.new(new_data)
      end

      def self.factory_method
        :namespace
      end
    end
  end
end
