module Aygabtu
  class RouteWrapper
    # Wraps a Journey route

    attr_reader :journey_route # ease debugging

    def initialize(journey_route)
      @journey_route = journey_route
    end

    def get?
      @journey_route.verb.match('GET')
    end

    def internal?
      # this particular route is hard to filter by any sensible criterion
      @journey_route.path.to_regexp == %r{\A/assets}
    end

    # array of parameter names (symbols) required for generating URL
    def required_parts
      @journey_route.required_parts
    end

    def controller
      @journey_route.requirements[:controller]
    end

    def controller_namespace
      return @controller_namespace if defined? @controller_namespace
      return @controller_namespace = nil unless controller

      @controller_namespace = Pathname('/').join(controller).dirname.to_s[1..-1]
      @controller_namespace = nil if @controller_namespace.empty?
      @controller_namespace
    end

    def controller_basename
      Pathname(controller).basename.to_s if controller
    end

    def action
      @journey_route.requirements[:action]
    end

    def name
      @journey_route.name.to_s if @journey_route.name
    end

    def matches_string?(string)
      @journey_route.path.to_regexp.match(string)
    end

    # this assumes parameters.keys == required_parts
    def generate_url_with_proper_parameters(parameters)
      @journey_route.format(parameters)
    end

    def inspect
      if @journey_route.name
        "route named :#{@journey_route.name}"
      else
        "route matching #{@journey_route.path.to_regexp.inspect}"
      end
    end

    def example_message
      "passes aygabtu assertions for #{inspect}"
    end

    def format(pass_data)
      @journey_route.format(pass_data)
    end

    def really_required_keys
      @journey_route.required_keys.map(&:to_s) - ['controller', 'action']
    end

    def touch!
      @touched = true
    end

    def touched?
      @touched
    end
  end
end
