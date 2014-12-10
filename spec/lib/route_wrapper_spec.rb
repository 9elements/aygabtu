require 'rails_application_helper'

require 'aygabtu/rspec'

require 'support/identifies_routes'

#require 'pry-byebug'

Rails.application.routes.draw do
  extend IdentifiesRoutes

  get 'bogus', identified_by(:test_identification).merge(to: 'bogus#bogus')

  get 'bogus', identified_by(:has_implicit_controller).merge(to: 'foo#bogus')
  get 'bogus', identified_by(:has_explicit_controller).merge(controller: :foo, action: :bogus)
  get 'bogus', identified_by(:no_controller).merge(to: redirect('/'))
  namespace "namespace" do
    get 'bogus', identified_by(:namespaced_controller).merge(to: 'foo#bogus')
  end
  get 'bogus', identified_by(:unnamespaced_controller).merge(to: 'foo#bogus')
  namespace 'namespace' do
    get 'bogus', identified_by(:namespaced_no_controller).merge(to: redirect('/'))
  end

  get 'bogus', identified_by(:has_implicit_action).merge(to: 'bogus#foo')
  get 'bogus', identified_by(:has_explicit_action).merge(controller: :bogus, action: :foo)
  get 'bogus', identified_by(:no_action).merge(to: redirect('/'))

  get 'name', identified_by(:explicitly_named).merge(to: 'bogus#bogus')

  get '/:segment/*glob/bogus', identified_by(:has_segments).merge(to: 'bogus#bogus')
end


describe "RouteWrapper", bundled: true do
  include IdentifiesRoutes

  include Aygabtu::RSpec.example_group_module

  describe "#controller" do
    context "for a route to a controller" do
      it "has that controller" do
        expect(route_identified_by(:has_implicit_controller).controller).to be == 'foo'
        expect(route_identified_by(:has_explicit_controller).controller).to be == 'foo'
      end
    end

    context "for a route not to a controller" do
      it "has nil as controller" do
        expect(route_identified_by(:no_controller).controller).to be_nil
      end
    end

    context "for a route to a namespaced contoller" do
      it "has namespace/controller as controller attribute" do
        expect(route_identified_by(:namespaced_controller).controller).to be == 'namespace/foo'
      end
    end
  end

  describe "#action" do
    context "for a route to a controller" do
      it "has the declared action" do
        expect(route_identified_by(:has_implicit_action).action).to be == 'foo'
        expect(route_identified_by(:has_explicit_action).action).to be == 'foo'
      end
    end

    context "for a route not to a controller" do
      it "has nil as action" do
        expect(route_identified_by(:no_action).action).to be_nil
      end
    end
  end

  describe "#name" do
    it "has the declared name for an explicitly named route" do
      expect(route_identified_by(:explicitly_named).name).to be == 'name'
    end
  end

  describe "#controller_namespace" do
    it "has the namespace of a namespaced route" do
      expect(route_identified_by(:namespaced_controller).controller_namespace).to be == 'namespace'
    end

    it "has nil namespace of an unnamespaced route" do
      expect(route_identified_by(:unnamespaced_controller).controller_namespace).to be_nil
    end

    it "has nil namespace of a namespaced route not routing to a controller" do
      expect(route_identified_by(:namespaced_no_controller).controller_namespace).to be_nil
    end
  end

  describe "#controller_basename" do
    context "for a route to a controller" do
      it "has that controller basename" do
        expect(route_identified_by(:has_implicit_controller).controller_basename).to be == 'foo'
        expect(route_identified_by(:has_explicit_controller).controller_basename).to be == 'foo'
      end
    end

    context "for a namespaced route to a controller" do
      it "has that controller basename" do
        expect(route_identified_by(:namespaced_controller).controller_basename).to be == 'foo'
      end
    end

    it "has nil controller_basename fo route not routing to a controller" do
      expect(route_identified_by(:no_controller).controller_basename).to be_nil
    end
  end

  describe "#really_required_keys" do
    context "for a route without any segments" do
      it "has no really_required_keys" do
        expect(route_identified_by(:has_implicit_controller).really_required_keys).to be_empty
      end
    end

    context "for a route with segments" do
      it "has these as really_required_keys" do
        expect(route_identified_by(:has_segments).really_required_keys).to \
          contain_exactly('segment', 'glob')
      end
    end
  end

  # all routes seen by route_identified_by
  def all_routes
    matching_routes
  end

  def matching_routes
    # we only test those routes facing aygabtu example groups, when fex. non-get routes have already been filtered out
    self.class.aygabtu_matching_routes
  end
end
