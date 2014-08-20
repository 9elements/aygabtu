require_relative 'route_wrapper'
require_relative 'scope_actor'

module Aygabtu
  class Handle

    def routes
      @routes ||= Rails.application.routes.set.map do |journey_route|
        RouteWrapper.new(journey_route)
      end.select(&:get?).reject(&:internal?)
    end

  end
end
