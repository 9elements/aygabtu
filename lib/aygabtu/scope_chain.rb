require_relative 'scope/base'

GEM_ROOT = Pathname(__FILE__).parent.to_s

module Aygabtu
  class ScopeChain
    def initialize(&context_block)
      @scope = Scope::Base.blank_slate
      @context_block = context_block
    end

    attr_writer :context_block

    attr_reader :point_of_definition

    Scope::Base.factory_methods.each do |factory_method|
      define_method(factory_method) do |*args, &block|
        new_scope = @scope.public_send(factory_method, *args)
        new_chain = clone
        new_chain.scope = new_scope
        new_chain.point_of_definition = find_point_of_definition

        @context_block.call(new_chain, block) if block

        new_chain
      end
    end

    protected

    attr_accessor :scope
    attr_writer :point_of_definition

    private

    def find_point_of_definition
      caller.drop_while { |point| point.start_with?(GEM_ROOT) }.first
    end
  end
end
