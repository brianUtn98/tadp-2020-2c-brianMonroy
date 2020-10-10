require 'rspec'




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

module Contrato

  def self.included(base)
    base.extend(BeforeAndAfter)
  end

end



module BeforeAndAfter

  #before y after comienzan en nul, seran seteadas por before_and_after_each_call , pre y post.


  @before = nil
  @after = nil
  #defino before and after, como metodos de clase
  class << self
    attr_reader :before , :after
  end


  def method_added(sym)
    return if @working

    original_method = instance_method(sym)

    @working = true

    proc_invariants = invariants

    proc_before = before

    proc_after = after


    define_method(sym) do |*argumentos|

      unless @before
        raise PreConditionError.new(sym) unless instance_eval(&proc_before)
      end

      resultado = original_method.bind(self).call(*argumentos)

      # TODO las invariantes hay que pedirlas en el momento para contemplar nuevas.
      proc_invariants.each do |oneInvariant|
        unless oneInvariant
          raise InvariantError.new(sym) unless instance_eval(&oneInvariant)
        end
      end

      unless @after
        raise PostConditionError.new(sym) unless instance_eval(&proc_after)
      end
      resultado

    end
    @before = nil
    @after = nil
    @working = false
  end

  def before_and_after_each_call(before = proc{},after = proc{})
    @before = before
    @after = after
  end

  def invariant(&block)
    #puts "Agregando una invariant"
    @invariants ||= []
    @invariants << block
  end

  def pre(&pre_condicion)
    @before = pre_condicion
  end

  def post(&post_condicion)
    @after = post_condicion
  end

  def invariants
    @invariants ||= [proc { true }]
  end

  def before
    @before ||= proc { true }
  end

  def after
    @after ||= proc { true }
  end

end


