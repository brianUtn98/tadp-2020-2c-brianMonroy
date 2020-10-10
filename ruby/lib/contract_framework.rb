require 'rspec'
require_relative 'errores'




# TODO sacarme este pasamanos

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

  def decored_methods
    @decored_methods
  end

  def add_decorated_method method
    @decored_methods ||= []
    @decored_methods.push method
  end

  def original_methods
    @original_methods
  end

  def add_original_method method
    @original_methods ||= []
    @original_methods.push method
  end

end


