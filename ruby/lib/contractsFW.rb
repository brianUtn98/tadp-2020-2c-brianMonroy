require 'rspec'

#codigo extraido de la clase 5
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


#mixin de invariants -> metodo invariant, controlarInvariant
module Invariants
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
      raise Exception, "No se cumplieron las invariantes" unless contexto.instance_eval(&invariante)
    end
  end
end

module Redefinicion
  include Invariants
  class << self
    attr_accessor :before, :after
  end

  @before = nil
  @after = nil

  def before_and_after_each_call(before = proc {},after = proc {})
    @before = before
    @after = after
  end

  def after
    @after
  end

  def before
    @before
  end

  protected def contexto_metodo (metodo,argumentos)
    Prototipo.new self
  end

  protected def ejecutar_pre(contexto)
    before.call(contexto)
  end

  protected def ejecutar_post(contexto)
    after.call(contexto)

  end


  def self.method_added sym

    return if @agregando_metodo

    puts "Agregando metodo #{sym}"

    @agregando_metodo = true

    metodo_original = self.instance_method(sym)

    self.define_method(sym) do |*argumentos|

      contexto = contexto_metodo metodo_original,argumentos

      puts "Redefiniendo metodo #{sym}"

      resultado = metodo_original.bind(contexto.contexto).call(*argumentos)

      self.class.send(:controlarInvariants,contexto.contexto)

      self.class.send(:ejecutar_pre,contexto.contexto)

      resultado

      self.class.send(:ejecutar_post,contexto.contexto)
    end
  end



end