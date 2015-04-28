module Aygabtu

class RouteMark
  def initialize(action, poc, checkpoint)
    @action, @poc, @checkpoint = action, poc, checkpoint
  end
  attr_reader :action, :poc, :checkpoint

  def conflicting?(other)
    !(action == :visit && other.action == :visit)
  end

  def description
    "#{action} action at #{poc} (CP #{checkpoint})"
  end
end

end
