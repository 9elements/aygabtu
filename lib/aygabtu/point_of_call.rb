require_relative 'scope/base'

GEM_ROOT = Pathname(__FILE__).parent.to_s

module Aygabtu
  module PointOfCall
    extend self

    def point_of_call
      caller.drop_while { |point| point.start_with?(GEM_ROOT) }.first
    end

    def file_and_line_at_point_of_call
      filename, line_and_context = point_of_call.split(':', 2)
      [filename, line_and_context.to_i] # make use of the fact to_i tolerates being passed a string only _beginning_ with a number
    end
  end
end
