require 'rails_application_helper'

require 'aygabtu/rspec'

require 'support/identifies_routes'
require 'support/aygabtu_sees_routes'
require 'support/matcher_shims'

describe "aygabtu scopes and their matching routes" do
  # make routes_for_scope a hash shared by all example groups below
  def self.routes_for_scope
    return superclass.routes_for_scope if superclass.respond_to?(:routes_for_scope)
    @routes_for_scope ||= {}
  end

  context "setup for anything but the remaining scope" do
    # This context contains no examples, but collects matching routes in different
    # contexts that are used by examples later on in this file.

    extend AygabtuSeesRoutes
    include Aygabtu::RSpec.example_group_module

    aygabtu_sees_routes do
      get 'bogus', identified_by(:controller_route).merge(to: 'controller_a#bogus')

      namespace "namespace" do
        get 'bogus', identified_by(:namespaced_controller_route).merge(to: 'controller_a#bogus')

        get 'bogus', identified_by(:namespaced_and_named).merge(to: 'bogus#bogus', as: 'name')

        namespace :another_namespace do
          get 'bogus', identified_by(:deeply_namespaced).merge(to: 'controller_a#bogus')
        end
      end

      get 'bogus', identified_by(:action_route).merge(to: 'bogus#some_action')
      get 'bogus', identified_by(:another_action_route).merge(to: 'bogus#other_action')

      get ':segment', identified_by(:with_segment).merge(to: 'bogus#bogus')
      get '*glob', identified_by(:with_glob).merge(to: 'bogus#bogus')

      get ':first_segment/:second_segment', identified_by(:two_segments).merge(to: 'bogus#bogus')

      get 'implicitly_named', identified_by(:implicitly_named).merge(to: 'bogus#bogus')
      get 'bogus', identified_by(:explicitly_named).merge(to: 'bogus#bogus', as: :explicitly_named)
    end

    controller(:controller_a) do
      routes_for_scope['controller controller_a'] = aygabtu_matching_routes
    end

    controller('namespace/controller_a') do
      routes_for_scope['controller namespace/controller_a'] = aygabtu_matching_routes
    end

    action(:some_action) do
      routes_for_scope['action some_action'] = aygabtu_matching_routes
    end

    action(:some_action, :other_action) do
      routes_for_scope['action with multiple args'] = aygabtu_matching_routes
    end

    namespace('namespace') do
      routes_for_scope['namespace namespace'] = aygabtu_matching_routes

      controller(:controller_a) do
        routes_for_scope['namespace namespace controller controller_a'] = aygabtu_matching_routes
      end

      namespace(:another_namespace) do
        routes_for_scope['namespace namespace namespace another_namespace'] = aygabtu_matching_routes
      end
    end

    namespace('namespace/another_namespace') do
      routes_for_scope['namespace namespace/another_namespace'] = aygabtu_matching_routes
    end

    named(:implicitly_named) do
      routes_for_scope['named implicitly_named'] = aygabtu_matching_routes
    end

    named(:explicitly_named) do
      routes_for_scope['named explicitly_named'] = aygabtu_matching_routes
    end

    named(:explicitly_named, :implicitly_named) do
      routes_for_scope['named with multiple args'] = aygabtu_matching_routes
    end

    requiring(:segment) do
      routes_for_scope['requiring segment'] = aygabtu_matching_routes
    end

    requiring(:glob) do
      routes_for_scope['requiring glob'] = aygabtu_matching_routes
    end

    requiring(:first_segment, :second_segment) do
      routes_for_scope['requiring multiple args'] = aygabtu_matching_routes
    end

    dynamic_routes do
      routes_for_scope['dynamic_routes'] = aygabtu_matching_routes
    end

    static_routes do
      routes_for_scope['static_routes'] = aygabtu_matching_routes
    end

    namespace(:namespace).named(:namespace_name) do
      routes_for_scope['namespaced and named'] = aygabtu_matching_routes
    end
  end

  context "setup for the remaining scope" do
    # This context contains no examples, but collects matching routes in different
    # contexts that are used by examples later on in this file.

    extend AygabtuSeesRoutes
    include Aygabtu::RSpec.example_group_module

    aygabtu_sees_routes do
      get 'bogus', identified_by(:visited_initially).merge(to: 'bogus#visited_initially')
      get 'bogus', identified_by(:remaining_initially).merge(to: 'bogus#remaining_initially')
      get 'bogus', identified_by(:remaining_eventually).merge(to: 'bogus#remaining_eventually')
    end

    # don't generate examples here so we can use visit etc.
    def aygabtu_example_for(*) end

    action(:visited_initially).visit

    routes_for_scope['examples for remaining, remaining after initial visit'] =
      aygabtu_matching_routes(remaining)

    remaining do
      routes_for_scope['examples for remaining, nested in remaining, after initial visit'] =
        aygabtu_matching_routes

      action(:remaining_initially).visit

      routes_for_scope['examples for remaining, nested in remaining, after nested visit'] =
        aygabtu_matching_routes
      action(:remaining_initially).visit # this would generate an exception when matching no
      # route. we do not rely on that alone by capturing matching routes immediately above

      routes_for_scope['examples for remaining, nested in remaining, remaining after final visit'] = aygabtu_matching_routes(remaining)
      remaining do
        routes_for_scope['examples for remaining, nested in remaining, nested after final visit'] = aygabtu_matching_routes
      end
    end
  end

  include IdentifiesRoutes
  include MatcherShims

  describe 'matching routes' do
    # use the :scope metadata to define an example group's routes
    def self.routes
      @routes ||= routes_for_scope.delete(metadata.fetch(:scope)) || raise("bad scope key?")
    end

    # make these routes available to the group's examples
    def routes
      self.class.routes
    end

    shared_examples_for "namespaced controller scoping" do
      it "does not match unnamespaced controller route" do
        expect(routes).not_to include(be_identified_by(:controller_route))
      end

      it "matches namespaced controller route" do
        expect(routes).to include(be_identified_by(:namespaced_controller_route))
      end

      it "does not match controller route namespaced deeper" do
        expect(routes).not_to include(be_identified_by(:deeply_namespaced))
      end
    end

    describe 'controller scoping' do
      context "scope", scope: 'controller controller_a' do
        it "matches unnamespaced controller route" do
          expect(routes).to include(be_identified_by(:controller_route))
        end

        it "does not match namespaced controller route" do
          expect(routes).not_to include(be_identified_by(:namespaced_controller_route))
        end
      end

      context "scope", scope: 'controller namespace/controller_a' do
        include_examples "namespaced controller scoping"
      end
    end

    describe 'namespace scoping' do
      context "scope", scope: 'namespace namespace' do
        it "matches namespaced route" do
          expect(routes).to contain_exactly(
            be_identified_by(:namespaced_controller_route),
            be_identified_by(:namespaced_and_named),
            be_identified_by(:deeply_namespaced)
          )
        end
      end

      shared_examples_for "namespace nesting" do
        it "matches deeply namespaced route" do
          expect(routes).to contain_exactly(be_identified_by(:deeply_namespaced))
        end
      end

      context "scope", scope: 'namespace namespace namespace another_namespace' do
        include_examples "namespace nesting"
      end

      context "scope", scope: 'namespace namespace/another_namespace' do
        include_examples "namespace nesting"
      end
    end

    describe 'combined namespace controller scoping' do
      context "scope", scope: 'namespace namespace controller controller_a' do
        include_examples "namespaced controller scoping"
      end
    end

    describe 'action scoping' do
      context "scope", scope: 'action some_action' do
        it "matches route with given action" do
          expect(routes).to contain_exactly(be_identified_by(:action_route))
        end
      end

      context "scope", scope: 'action with multiple args' do
        it "matches routes with given actions" do
          expect(routes).to contain_exactly(
            be_identified_by(:action_route),
            be_identified_by(:another_action_route)
          )
        end
      end
    end

    describe 'named scoping' do
      context "scope", scope: 'named implicitly_named' do
        it "matches implicitly named route" do
          expect(routes).to contain_exactly(be_identified_by(:implicitly_named))
        end
      end

      context "scope", scope: 'named explicitly_named' do
        it "matches explicitly named route" do
          expect(routes).to contain_exactly(be_identified_by(:explicitly_named))
        end
      end

      context "scope", scope: 'named with multiple args' do
        it "matches given named routes" do
          expect(routes).to contain_exactly(
            be_identified_by(:explicitly_named),
            be_identified_by(:implicitly_named)
          )
        end
      end
    end

    describe 'requiring scoping' do
      context "scope", scope: 'requiring segment' do
        it "matches route requiring given segment" do
          expect(routes).to contain_exactly(be_identified_by(:with_segment))
        end
      end

      context "scope", scope: 'requiring glob' do
        it "matches route requiring given glob" do
          expect(routes).to contain_exactly(be_identified_by(:with_glob))
        end
      end

      context "scope", scope: 'requiring multiple args' do
        it "matches route requiring given segments" do
          expect(routes).to contain_exactly(be_identified_by(:two_segments))
        end
      end
    end

    describe "static_routes / dynamic_routes scoping" do
      context "scope", scope: 'dynamic_routes' do
        it "matches route requiring any segment or glob" do
          expect(routes).to contain_exactly(
            be_identified_by(:with_segment),
            be_identified_by(:with_glob),
            be_identified_by(:two_segments)
          )
        end
      end

      context "scope", scope: 'static_routes' do
        it "matches route not requiring any segment or glob" do
          expect(routes).not_to be_empty
          expect(routes).not_to include(be_identified_by(:with_segment))
          expect(routes).not_to include(be_identified_by(:with_glob))
        end
      end
    end

    describe "combined scoping" do
      context "scope", scope: 'namespaced and named' do
        it "matches route matching both criteria" do
          expect(routes).to include(be_identified_by(:namespaced_and_named))
        end
      end
    end

    describe "remaining scoping" do
      shared_examples_for "remaining routes right after initial visit" do
        it "does not match route visited before" do
          expect(routes).not_to include(be_identified_by(:visited_initially))
        end

        it "matches routes not visited before" do
          expect(routes).to include(
            be_identified_by(:remaining_initially),
            be_identified_by(:remaining_eventually)
          )
        end
      end

      context "scope", scope: 'examples for remaining, remaining after initial visit' do
        it_behaves_like "remaining routes right after initial visit"
      end

      context "scope", scope: 'examples for remaining, nested in remaining, after initial visit' do
        it "does not match route visited before" do
          expect(routes).not_to include(be_identified_by(:visited_initially))
        end

        it "matches routes not visited before" do
          expect(routes).to include(
            be_identified_by(:remaining_initially),
            be_identified_by(:remaining_eventually)
          )
        end
      end

      context "scope", scope: 'examples for remaining, nested in remaining, after nested visit' do
        it_behaves_like "remaining routes right after initial visit"
      end

      shared_examples_for "remaining routes after nested visit" do
        it "does not match route visited before" do
          expect(routes).not_to include(be_identified_by(:visited_initially))
          expect(routes).not_to include(be_identified_by(:remaining_initially))
        end

        it "matches routes not visited before" do
          expect(routes).to include(be_identified_by(:remaining_eventually))
        end
      end

      context "scope", scope: 'examples for remaining, nested in remaining, remaining after final visit' do
        it_behaves_like "remaining routes after nested visit"
      end

      context "scope", scope: 'examples for remaining, nested in remaining, nested after final visit' do
        it_behaves_like "remaining routes after nested visit"
      end
    end
  end

  after(:all) do
    next if self.class.routes_for_scope.empty?

    $stderr.puts "Sanity check failed: not all saved configurations have been asserted against"
    # RSpec tries hard to take full control and exit the process normally,
    # so we apply a lot of force here.
    Kernel.exit! 1
  end
end
