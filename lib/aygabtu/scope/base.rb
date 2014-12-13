require_relative 'namespace_controller'
require_relative 'action'
require_relative 'named'
require_relative 'visiting_with'
require_relative 'requiring'
require_relative 'static_dynamic'
require_relative 'remaining'

module Aygabtu
  module Scope
    class Base
      def initialize(data)
        @data = data
      end

      def visiting_data
        @data.fetch(:visiting_data, {})
      end

      def self.blank_slate
        new(filters: [])
      end

      COMPONENTS = [
        NamespaceController,
        Action,
        Named,
        VisitingWith,
        Requiring,
        StaticDynamic,
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

        def inspect_data
          {}
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

      def inspect
        data = inspect_data
        data.keys.each { |key| data.delete(key) if data[key].nil? }
        message = if data.empty?
          "nothing specified"
        else
          data.map { |key, value| "#{key}: #{value}" }.join(', ')
        end
        "\#<Aygabtu scope (#{message})>"
      end

      @factory_methods = COMPONENTS.map(&:factory_methods).reduce([], :+)

      class << self
        attr_reader :factory_methods
      end

      private

      def inspected_or_nil(obj)
        obj.inspect unless obj.nil?
      end
    end
  end
end
