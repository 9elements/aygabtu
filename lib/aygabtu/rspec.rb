require_relative 'matcher'

module Aygabtu
  module RSpec

    module ExampleGroupMethods
      delegate(*Matcher.factory_methods, to: Matcher)

      def ignore(*)
      end
    end

    module ExampleGroupModule
      def self.included(group)
        group.extend ExampleGroupMethods
      end
    end

    class << self
      def example_group_module
        ExampleGroupModule
      end
    end
  end
end
