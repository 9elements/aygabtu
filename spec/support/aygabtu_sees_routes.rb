require 'support/identifies_routes'

module AygabtuSeesRoutes
  def aygabtu_sees_routes(&block)
    engine = Class.new(Rails::Engine)
    engine.instance.routes.draw do
      # Rails evaluates the block given inside the context of
      # some routing related object. Since we do not want to repeat
      # the following line every time this method is called,
      # we need to to this instance_eval trick.
      extend IdentifiesRoutes
      instance_eval(&Proc.new)
    end
    aygabtu_handle.send(:rails_application_routes=, engine.routes)
  end
end

