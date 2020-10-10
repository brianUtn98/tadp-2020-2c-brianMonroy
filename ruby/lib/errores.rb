class InvariantError < StandardError
  def initialize(sym)
    super "No se cumplio una invariante en el metodo #{sym}"
  end
end

class PreConditionError < StandardError
  def initialize(sym)
    super "No se cumplio la pre-condicion en el metodo #{sym}"
  end
end

class PostConditionError < StandardError
  def initialize(sym)
    super "No se cumplio la post-condicion en el metodo #{sym}"
  end
end
