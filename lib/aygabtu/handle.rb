require_relative 'route_wrapper'
require_relative 'scope_actor'

module Aygabtu
  class Handle

    def routes
      @routes ||= rails_application_routes.set.map do |journey_route|
        RouteWrapper.new(journey_route)
      end.select(&:get?).reject(&:internal?)
    end

    private

    def rails_application_routes
      @rails_application_routes ||= Rails.application.routes
    end
    attr_writer :rails_application_routes
  end
end
