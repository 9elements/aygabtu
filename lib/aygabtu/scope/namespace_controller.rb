module Aygabtu
  module Scope
    module NamespaceController
      def namespace(name)
        raise "nesting/chaining namespace in/after controller makes no sense" if @data[:controller]
        raise "nesting/chaining namespace in/after action makes no sense" if @data[:action]

        new_namespace = Pathname(@data[:namespace] || '').join(name.to_s).to_s
        new_data = @data.dup.merge(namespace: new_namespace)
        self.class.new(new_data)
      end

      def controller(name)
        raise "nesting/chaining controller scopes makes no sense" if @data[:controller]
        raise "nesting/chaining namespace in/after action makes no sense" if @data[:action]

        new_controller = name.to_s
        new_data = @data.dup.merge(controller: new_controller)
        self.class.new(new_data)
      end

      def matches_route?(route)
        namespace, controller = @data[:namespace], @data[:controller]

        return false if (namespace || controller) && !route.controller
        return super unless namespace || controller

        namespace = Pathname(namespace || '')
        path = namespace.join(controller || '').to_s
        if controller
          path == route.controller
        else
          controller_namespace = route.controller_namespace || ''
          (controller_namespace + '/').start_with?(path + '/')
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

