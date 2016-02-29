module IdentifiesRoutes
  def identified_by(identifier)
    { defaults: { route_identifier: identifier } }
  end

  def be_identified_by(identifier)
    satisfy { |rw| rw.journey_route.defaults[:route_identifier] == identifier }
  end

  def route_identified_by(identifier, all_routes = all_routes())
    identified_routes = all_routes.select do |rw|
      rw.journey_route.defaults[:route_identifier] == identifier
    end
    expect(identified_routes.length).to be == 1
    identified_routes.first
  end
end

