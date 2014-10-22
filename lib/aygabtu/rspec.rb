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
          class_exec(&block)
        end
      end

      def aygabtu_action(action, scope, *args)
        ScopeActor.new(scope, aygabtu_handle.routes, self).public_send(action, *args)
      end

      def aygabtu_handle
        if superclass.respond_to?(:aygabtu_handle)
          superclass.aygabtu_handle
        else
          @_aygabtu_handle ||= Handle.new
        end
      end

      def aygabtu_matching_routes(scope = aygabtu_scope)
        scope = scope.scope if scope.respond_to?(:scope) # a scope chain can be pased as well
        aygabtu_handle.routes.select do |route|
          scope.matches_route?(route)
        end
      end

      ScopeActor.actions.each do |action|
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

      def aygabtu_example_for(path)
        visit path
        aygabtu_assertions
      end

      attr_accessor :aygabtu_path_to_visit

      def aygabtu_pass_to_route(id, pass_data)
        route = self.class.aygabtu_handle.routes.find { |a_route| a_route.object_id == id }

        pass_data = pass_data.clone
        pass_data.keys.each do |key|
          value = pass_data[key]
          pass_data[key] = aygabtu_fetch_symbolic_pass_value(value) if value.is_a?(Symbol)
        end

        missing_keys = route.really_required_keys - pass_data.keys.map(&:to_s)

        if missing_keys.empty?
          route.format(pass_data)
        else
          raise "Route is missing required key(s) #{missing_keys.map(&:inspect).join(', ')}"
        end
      end

      def aygabtu_fetch_symbolic_pass_value(symbol)
        raise "Symbolic pass value #{symbol} given, but no such method defined" unless respond_to?(symbol)
        send(symbol)
      end

      def aygabtu_assert_status_success
        expect(page.status_code).to be 200
      end

      def aygabtu_assert_not_redirected_away # @TODO create custom rspec matcher to provide cleaner error messages
        uri = URI(current_url)
        uri.host = nil
        uri.scheme = nil
        expect(uri.to_s).to be == aygabtu_path_to_visit
      end

      def aygabtu_assertions
        raise "Hey aygabtu user, please implement this yourself by overriding the aygabtu_assert method!"
      end
    end

    class << self
      def example_group_module
        ExampleGroupModule
      end
    end
  end
end
