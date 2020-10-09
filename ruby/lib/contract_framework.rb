require 'rspec'




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
    attr_reader :before,:after
  end

  def method_added(sym)
    return if @working

    original_method = instance_method(sym)

    @working = true

    proc_invariants = invariants

    proc_before = before

    proc_after = after


    define_method(sym) do |*argumentos|

      raise "No se cumplio la pre-condicion" unless instance_eval(&proc_before)

      resultado = original_method.bind(self).call(*argumentos)

      # TODO las invariantes hay que pedirlas en el momento para contemplar nuevas.
      proc_invariants.each do |oneInvariant|
        raise "No se cumplio la invariante" unless instance_eval(&oneInvariant)
      end

      raise "No se cumplio la post-condicion" unless instance_eval(&proc_after)
      resultado

    end
    proc_limpieza = proc { true }
    @before = proc_limpieza
    @after = proc_limpieza
    @working = false
  end

  def before_and_after_each_call(before = proc{},after = proc{})
    @before = before
    @after = after
  end

  def invariant(&block)
    puts "Agregando una invariant"
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


