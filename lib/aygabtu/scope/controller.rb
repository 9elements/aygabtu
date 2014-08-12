module Aygabtu
  module Scope
    module Controller
      def controller(name)
        new_data = @data.dup
        new_data[:filters] = [*@data[:filters], name]
        self.class.new(new_data)
      end

      def self.factory_method
        :controller
      end
    end
  end
end
