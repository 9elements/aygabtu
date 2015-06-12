require_relative 'scope/base'

module Aygabtu

  module PointOfCall
    extend self

    def point_of_call
      caller.drop_while { |point| point.start_with?(PointOfCall.gem_root) }.first
    end

    def file_and_line_at_point_of_call
      filename, line_and_context = point_of_call.split(':', 2)
      [filename, line_and_context.to_i] # make use of the fact to_i tolerates being passed a string only _beginning_ with a number
    end

    def self.gem_root
      @gem_root ||= begin
        path = Pathname(__FILE__)
        while new_path = path.parent and new_path.to_s.include?('lib/aygabtu')
          path = new_path
        end

        path.to_s
      end
    end
  end
end
