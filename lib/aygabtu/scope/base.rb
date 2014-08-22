require_relative 'namespace'
require_relative 'controller'
require_relative 'path'
require_relative 'named'
require_relative 'passing'
require_relative 'requiring'
require_relative 'remaining'

module Aygabtu
  module Scope
    class Base
      def initialize(data)
        @data = data
      end

      def pass_data
        @data.fetch(:passing, {})
      end

      def self.blank_slate
        new(filters: [])
      end

      COMPONENTS = [
        Namespace,
        Controller,
        Path,
        Named,
        Passing,
        Requiring,
        Remaining
      ]

      module BasicBehaviour
        # defines methods below COMPONENTS in the inheritance chain
        # so components can override and call super

        def matches_route?(route)
          true
        end

        def segments_split_once
        end
      end
      include BasicBehaviour

      include(*COMPONENTS)

      def segments
        if split_once = segments_split_once
          split_once.map(&:segments).reduce(:+)
        else
          [self]
        end
      end

      @factory_methods = COMPONENTS.map do |component|
        component.try(:factory_method)
      end.compact

      class << self
        attr_reader :factory_methods
      end
    end
  end
end
