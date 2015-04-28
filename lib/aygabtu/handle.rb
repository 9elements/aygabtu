require_relative 'route_wrapper'
require_relative 'scope_actor'

module Aygabtu
  class Handle

    def routes
      @routes ||= rails_application_routes.set.map do |journey_route|
        RouteWrapper.new(journey_route)
      end.select(&:get?).reject(&:internal?)
    end

    def checkpoint
      @checkpoint || 0
    end

    def next_checkpoint
      checkpoint + 1
    end

    def bump_checkpoint!
      @checkpoint = next_checkpoint
      puts "Bumped checkpoint to #{@checkpoint}" if verbose?
    end

    def generate_checkpoint
      bump_checkpoint!
      checkpoint
    end

    def verbose!
      @verbose = true
    end

    def verbose?
      !!@verbose
    end

    private

    def rails_application_routes
      @rails_application_routes ||= Rails.application.routes
    end
    attr_writer :rails_application_routes
  end
end
