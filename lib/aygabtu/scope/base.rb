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

      module AlwaysMatches
        def matches_route?(route)
          true
        end
      end
      include AlwaysMatches

      module UnSegmented
        def segments_split_once
        end
      end
      include UnSegmented

      def segments
        if split_once = segments_split_once
          split_once.map(&:segments).reduce(:+)
        else
          [self]
        end
      end

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
