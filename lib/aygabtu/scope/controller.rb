module Aygabtu
  module Scope
    module Controller
      def controller(name)
        raise "nesting/chaining controller in/after controller makes no sense" if @data[:controller]

        full_name = Pathname('/').join(@data[:namespace] || '').join(name.to_s)

        new_namespace = full_name.dirname.to_s[1..-1] # strip leading slash
        new_namespace = nil if new_namespace.empty?

        controller_name = full_name.basename.to_s

        new_data = @data.dup.merge(namespace: new_namespace, controller: controller_name)
        self.class.new(new_data)
      end

      def matches_route?(route)
        # namespace matching is handled by namespace module
        if @data[:controller]
          route.controller_basename &&
            route.controller_basename == @data[:controller]
        else
          true
        end && super
      end

      def inspect_data
        super.merge(controller: inspected_or_nil(@data[:controller]))
      end

      def self.factory_method
        :controller
      end
    end
  end
end
