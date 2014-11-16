require 'rails_application_helper'

require 'aygabtu/rspec'

Rails.application.routes.draw do
  scope module: :namespace do
    get ':segment', to: 'bogus#action'
  end
end

describe "nesting and chaining scopes", bundled: true do
  include Aygabtu::RSpec.example_group_module

  ReportException  = Class.new(Exception)

  def visit(path)
    nested_unnested = path[1..-1]
    raise ReportException, Marshal.dump(nested_unnested)
  end

  def aygabtu_assertions
  end

  namespace(:namespace) do
    action(:action).pass(segment: "nested")
  end

  namespace(:namespace).action(:action).pass(segment: "unnested")
end

