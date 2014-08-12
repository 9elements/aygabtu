require_relative 'scope/base'
require_relative 'scope_chain'

module Aygabtu
  module RSpec

    module ExampleGroupMethods
      delegate(*Scope::Base.factory_methods, to: :aygabtu_scope_chain)

      def aygabtu_scope_chain
        @aygabtu_scope_chain ||= if superclass.respond_to?(:aygabtu_scope_chain)
          superclass.aygabtu_scope_chain
        else
          ScopeChain.new(&method(:aygabtu_change_context))
        end
      end

      def aygabtu_change_context(new_chain, context_block)
        context "Context defined at #{new_chain.point_of_definition}" do
          # inside a different example group now!
          # thus, the following line needs to be inside this block
          new_chain.context_block = method(:aygabtu_change_context)
          @aygabtu_scope_chain = new_chain
          instance_exec(&context_block)
        end
      end

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
