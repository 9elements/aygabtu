module Aygabtu
  module Scope
    module NamespaceController
      def namespace(name)
        raise "nesting/chaining namespace in/after controller makes no sense" if @data[:controller]
        new_namespace = Pathname(@data[:namespace] || '').join(name.to_s).to_s
        new_data = @data.dup.merge(namespace: new_namespace)
        self.class.new(new_data)
      end

      def controller(name)
        raise "nesting/chaining controller in/after controller makes no sense" if @data[:controller]

        new_controller = name.to_s
        new_data = @data.dup.merge(controller: new_controller)

#        full_name = Pathname('/').join(@data[:namespace] || '').join(name.to_s)
#
#        new_namespace = full_name.dirname.to_s[1..-1] # strip leading slash
#        new_namespace = nil if new_namespace.empty?
#
#        controller_name = full_name.basename.to_s
#
#        new_data = @data.dup.merge(namespace: new_namespace, controller: controller_name)
        self.class.new(new_data)
      end

      def matches_route?(route)
        namespace, controller = @data[:namespace], @data[:controller]

        return false if (namespace || controller) && !route.controller
        return super unless namespace || controller

        namespace = Pathname(namespace || '')

        if controller && controller.include?('/')
          path = namespace.join(controller).to_s
          route.controller == path
        else
          (!controller or route.controller_basename == controller) &&
            ((route.controller_namespace || '') + '/').start_with?(namespace.to_s + '/')
        end && super
      end

      def inspect_data
        super.merge(
          namespace: inspected_or_nil(@data[:namespace]),
          controller: inspected_or_nil(@data[:controller]))
      end

      def self.factory_methods
        [ :namespace, :controller ]
      end
    end
  end
end

