require 'rails_application_helper'

require 'aygabtu/rspec'

Rails.application.routes.draw do
  get 'bogus', to: 'bogus#visited', as: :named
  get 'bogus', to: 'bogus#pended'
  get 'bogus', to: 'bogus#ignored'

  get 'bogus', to: 'bogus#doubly_pended'
  get 'bogus', to: 'bogus#doubly_ignored'
  get 'bogus', to: 'bogus#pended_and_ignored'
  get 'bogus', to: 'bogus#passed_to_and_ignored'
  get 'bogus', to: 'bogus#passed_to_and_pended'
end

describe "failures for missing route matches", bundled: true do
  include Aygabtu::RSpec.example_group_module

  def visit(*)
  end

  def aygabtu_assertions
  end

  # All description string with CAPS are being parsed!

  context "not failing when a route matches" do
    context "EXAMPLE PASSING" do
      action(:visited).pass
      named(:named).pass
    end

    context "EXAMPLE PENDING" do
      action(:pended).pend "bogus reason"
    end

    context "NO EXAMPLE" do
      action(:ignored).ignore "bogus reason"
    end
  end

  context "EXAMPLE FAILING because no route matches" do
    action(:nonexiting).pass
    action(:nonexiting).pend "bogus reason"
    action(:nonexiting).ignore "bogus reason"
  end

  context "EXAMPLES PARTLY FAILING because one of the given routes does not match" do
    action(:visited, :nonexisting).pass

    named(:named, :nonexisting).pass
  end

  context "erroneously applying two actions to same route" do
    next if true # this would trigger an exception at load time.
    # we need to fix that before we can write these examples here.
    action(:doubly_pended).pend "bogus reason"
    action(:doubly_pended).pend "bogus reason"

    # more needed here. see routes.
  end

end

