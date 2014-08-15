module Aygabtu
  module Scope
    module Namespace
      def namespace(name)
        raise "nesting/chaining namespace in/after controller makes no sense" if @data[:controller]

        new_namespace = Pathname(@data[:namespace] || '').join(name.to_s).to_s
        new_data = @data.dup.merge(namespace: new_namespace)
        self.class.new(new_data)
      end

      def matches_route?(route)
        if @data[:namespace]
          route.controller_namespace &&
            (route.controller_namespace + '/').start_with?(@data[:namespace] + '/')
        else
          true
        end && super
      end

      def self.factory_method
        :namespace
      end
    end
  end
end
