require_relative 'scope/base'
require_relative 'scope_actor'

module Aygabtu
  class ScopeChain
    def initialize(example_group, scope)
      @example_group = example_group
      @scope = scope
    end

    attr_reader :scope

    Scope::Base.factory_methods.each do |factory_method|
      define_method(factory_method) do |*args, &block|
        new_scope = @scope.public_send(factory_method, *args)

        result = self.class.new(@example_group, new_scope)

        @example_group.aygabtu_enter_context(block, new_scope) if block

        result
      end
    end

    def remaining(&block)
      remaining_at(@example_group.aygabtu_handle.checkpoint, &block)
    end

    def self.scope_methods
      [:remaining, *Scope::Base.factory_methods]
    end

    ScopeActor.actions.each do |action|
      define_method(action) do |*args|
        @example_group.aygabtu_action(action, @scope, *args)
      end
    end
  end
end
