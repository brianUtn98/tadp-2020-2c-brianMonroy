#require 'to_source'
require 'rspec'

#extraido de la clase 5, no utilizado en la ultima version
class Prototipo
  attr_accessor :prototipo

  def initialize prototipo= Object.new
    self.prototipo = prototipo
  end

  def contexto
    self.prototipo
  end

  def set_property(sym, value)
    unless self.prototype.respond_to? sym
      self.singleton_class.send :attr_accessor, sym
      self.send "#{sym}=", value
    end
  end

  def set_method(sym, block)
    self.define_singleton_method sym, block
  end

  def set_prototype(proto)
    self.prototype = proto
  end

  def respond_to_missing?(sym, include_all = true)
    super(sym, include_all) or self.prototype.respond_to? sym
  end

  def method_missing(sym, *args)
    super unless self.respond_to? sym
    # method = self.prototype.method(sym).unbind
    # method.bind(self).call *args
    self.prototype.send(sym, *args)
  end
end


# no utilizado en la ultima version
module InvariantModule
  def invariantes
    @invariantes ||= []
    puts 'Llamada metodo invariantes'
    @invariantes
  end

  def invariant(&block)
    puts 'Definida una invariante'
    invariantes.push(block)
  end

  def controlarInvariants contexto
    puts "Controlando invariantes en instancia #{contexto}"
    invariantes.each do |invariante|
      puts "Evaluando invariante en #{contexto}"
      raise "No se cumplieron las invariantes" unless contexto.instance_eval(&invariante)
    end
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

  #defino before and after, como metodos de instancia
  class << self
    attr_reader :before,:after
  end

  # toda la logica imporatnte va dentro del method_added, un hook que nos proporciona ruby
  #
  def redefinir_metodo(sym)
    return if @working

    original_method = instance_method(sym)

    @working = true

    proc_invariants = invariants

    proc_before = before

    proc_after = after


    define_method(sym) do |*argumentos|

      # contexto = contexto_metodo original_method,argumentos
      # if sym == :controlarInvariants
      #   return
      # end

      if sym == :initialize
        #bindeo el metodo para poder llamarlo
        resultado = original_method.bind(self).call(*argumentos)
        proc_invariants.each do |oneInvariant|
          #puts invariant.to_source(strip_enclosure: true)
          raise "No se cumplio la invariante" unless instance_eval(&oneInvariant)
        end
        #self.validar_invariants

        #self.class.send(:controlarInvariants,contexto.contexto)
        #
        #controlarInvariants self
        #self.class.send(:controlarInvariants,self)

        resultado
      end
      raise "No se cumplio la pre-condicion" unless instance_eval(&proc_before)

      resultado = original_method.bind(self).call(*argumentos)

      proc_invariants.each do |oneInvariant|
        raise "No se cumplio la invariante" unless instance_eval(&oneInvariant)
      end

      #self.class.send(:controlarInvariants,contexto.contexto)

      #self.class.send(:controlarInvariants,self)
      #controlarInvariants self

      raise "No se cumplio la post-condicion" unless instance_eval(&proc_after)
      resultado

    end
    proc_limpieza = proc { true }
    @before = proc_limpieza
    @after = proc_limpieza
    @working = false
  end

  def method_added(sym)
    redefinir_metodo(sym)
  end

  #quise abstraer la logica esta, pero es mas sencillo hacerlo en method_added
  # def self.validar_invariants
  #   invariants.each do |unaInvariante|
  #     raise "No se cumplio la invariante" unless instance_eval(&unaInvariante)
  #   end
  # end


  def before_and_after_each_call(before = proc{},after = proc{})
    @before = before
    @after = after
  end

  # protected def contexto_metodo (metodo,argumentos)
  #   Prototipo.new self
  # end

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
#end
