require_relative 'handle'
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

      def aygabtu_action(action, scope, *args)
        aygabtu_handle.public_send(action, scope, self, *args)
      end

      def aygabtu_handle
        if superclass.respond_to?(:aygabtu_handle)
          superclass.aygabtu_handle
        else
          @_aygabtu_handle ||= Handle.new
        end
      end

      Handle.actions.each do |action|
        define_method(action) do |*args|
          aygabtu_action(action, aygabtu_scope, *args)
        end
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
