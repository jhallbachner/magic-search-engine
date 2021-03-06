class ConditionNot < Condition
  def initialize(cond)
    @cond = cond
    @simple = @cond.simple?
  end

  def include_extras?
    @cond.include_extras?
  end

  def search(db)
    db.printings - @cond.search(db)
  end

  def metadata=(options)
    super
    @cond.metadata = options
  end

  def match?(card)
    raise unless @simple
    not @cond.match?(card)
  end

  def simple?
    @simple
  end

  def to_s
    "(not #{@cond})"
  end
end
