require_relative 'scope/base'

GEM_ROOT = Pathname(__FILE__).parent.to_s

module Aygabtu
  module PointOfCall
    extend self

    def point_of_call
      caller.drop_while { |point| point.start_with?(GEM_ROOT) }.first
    end
  end
end
