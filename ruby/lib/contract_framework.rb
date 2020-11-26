require_relative 'errores'

class Wrapper
  attr_accessor :context

  def initialize context
    @context = context
  end

  private def method_missing(symbol, *args)
    metodo= context.class.decorated_methods[symbol].bind(context)
    metodo.call(*args)
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?('user_') || super
  end
end

module BeforeAndAfter

  @before = nil
  @after = nil

  class << self
    attr_reader :before , :after,:invariants
  end


  def method_added(sym)
    puts "Dentro de method added self es #{self}, agregando metodo #{sym}"
    return if @working or self == Object or self == Module or self == Class or self==BasicObject or decorated_methods.has_key? :sym# o ya fue decorado, o es una clase del meta modelo

    original_method = instance_method(sym)


    @working = true

    proc_before = before

    proc_after = after

    add_decorated_method(sym,original_method)
    define_method(sym) do |*argumentos|
      puts "Dentro de define method self es una instancia de #{self.class}, defino metodo #{sym}"
      unless @before
        raise "Error de Pre-Condicion en #{self}:#{sym}" unless instance_eval(&proc_before)
      end

      resultado = original_method.bind(self).call(*argumentos)

      # TODO las invariantes hay que pedirlas en el momento para contemplar nuevas.
      self.class.invariants.each do |oneInvariant|
        raise "No se cumplio la invariante en #{self}:#{sym}" unless instance_eval(&oneInvariant)
      end

      unless @after
        raise "Error de Post-Condicion en #{self}:#{sym}" unless instance_eval(&proc_after)
      end
      resultado


    end
    @before = nil
    @after = nil
    @working = false

    super # para que rubymine no se queje
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

  def decorated_methods
    @decored_methods ||={}
  end

  def add_decorated_method sym,method
    puts "Entre al metodo add_decorated_method para el metodo #{sym}"
    @decored_methods ||= {}
    @decored_methods[sym] = method
    puts "Agregué el metodo #{sym} al hash"
    #@decored_methods.push metodo_decorado
  end

  private def getters
    @getters ||= []
  end

  private def add_getters(method_names)
    @getters = send(:getters) + method_names
  end

  private def reserved_methods
    [:irb_binding]
  end

  def generate_context object
    context = Wrapper.new object
    context
  end

end


