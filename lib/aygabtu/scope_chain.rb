require_relative 'scope/base'

GEM_ROOT = Pathname(__FILE__).parent.to_s

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
  end
end
