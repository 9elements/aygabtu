module Aygabtu

class RouteMark
  def initialize(action, poc)
    @action, @poc = action, poc
  end
  attr_reader :action, :poc

  def conflicting?(other)
    !(action == :visit && other.action == :visit)
  end
end

end
