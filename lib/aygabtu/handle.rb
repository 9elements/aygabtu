require_relative 'route_wrapper'
require_relative 'scope_actor'

module Aygabtu
  class Handle
    def initialize
      @verbose = false
    end

    def routes
      @routes ||= rails_application_routes.set.map do |journey_route|
        RouteWrapper.new(journey_route)
      end.select(&:get?).reject(&:internal?)
    end

    def checkpoint
      @checkpoint || 0
    end

    def generate_checkpoint
      @checkpoint = (checkpoint + 1).tap do |new_checkpoint|
        puts "New checkpoint #{new_checkpoint}" if verbose?
      end
    end

    def verbose!
      @verbose = true
    end

    def verbose?
      @verbose
    end

    private

    def rails_application_routes
      @rails_application_routes ||= Rails.application.routes
    end
    attr_writer :rails_application_routes
  end
end
