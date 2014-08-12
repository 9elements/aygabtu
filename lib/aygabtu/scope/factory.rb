require_relative 'base'
require_relative 'controller'
require_relative 'namespace'
require_relative 'path'

module Aygabtu
  module Scope
    module Factory

      FACTORY_MODULES = [
        Scope::Namespace,
        Scope::Controller,
        Scope::Path
      ]

      include(*FACTORY_MODULES)
      extend self

      delegate :new, to: 'Aygabtu::Scope::Base'

      def factory_methods
        FACTORY_MODULES.map(&:instance_methods).reduce(:+)
      end
    end
  end
end
