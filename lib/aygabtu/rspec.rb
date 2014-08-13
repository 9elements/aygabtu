require_relative 'scope/base'
require_relative 'scope_chain'
require_relative 'point_of_call'

module Aygabtu
  module RSpec

    module ExampleGroupMethods
      delegate(*Scope::Base.factory_methods, to: :aygabtu_scope_chain)

      def aygabtu_scope
        @aygabtu_scope ||= if superclass.respond_to?(:aygabtu_scope)
          superclass.aygabtu_scope
        else
          Scope::Base.blank_slate
        end
      end

      def aygabtu_scope_chain
        @aygabtu_scope_chain ||= ScopeChain.new(self, aygabtu_scope)
      end

      def aygabtu_enter_context(block, scope)
        context "Context defined at #{PointOfCall.point_of_call}" do
          self.aygabtu_scope = scope
          instance_exec(&block)
        end
      end

      def ignore(*)
      end

      private

      attr_writer :aygabtu_scope
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
