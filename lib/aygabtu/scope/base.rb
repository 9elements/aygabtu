require_relative 'namespace'
require_relative 'controller'
require_relative 'path'

module Aygabtu
  module Scope
    class Base
      def initialize(data)
        @data = data
      end

      def self.blank_slate
        new(filters: [])
      end

      COMPONENTS = [
        Namespace,
        Controller,
        Path
      ]

      module AlwaysMatches
        def matches_route?(route)
          true
        end
      end
      include AlwaysMatches

      include(*COMPONENTS)

      @factory_methods = COMPONENTS.map do |component|
        component.try(:factory_method)
      end.compact

      class << self
        attr_reader :factory_methods
      end
    end
  end
end
