require_relative 'errores'

class Module
  attr_reader :has_contract
end

class Wrapper
  attr_accessor :wrappedObject

  def initialize context
    @wrappedObject = context
  end

  private def method_missing(symbol, *args)
    if wrappedObject.class.decorated_methods.has_key? symbol
      metodo = wrappedObject.class.decorated_methods[symbol].bind(wrappedObject)
      metodo.call(*args)
    else
      super
    end
    end

  def respond_to_missing?(method_name, include_private = false)
    wrappedObject.respond_to_missing? method_name
  end
end

module BeforeAndAfter

  @before = nil
  @after = nil

    attr_reader :before , :after,:invariants

  def method_added(sym)

    return if Class.ancestors.include? self or decorated_methods.has_key? sym or !@has_contract

    original_method = self.instance_method(sym)

    proc_before = before

    proc_after = after

    argumentos_sym = original_method.parameters.map{|unArg| unArg[1].to_s}

    add_decorated_method(sym,original_method)
    define_method(sym) do |*argumentos|
      context = Wrapper.new self
      
      argumentos_sym.each_with_index do |arg,index|
        context.define_singleton_method(arg) do
          argumentos[index]
        end
      end

      unless proc_before.empty?
        proc_before.each do |onePre|
          raise "Error de Pre-Condicion en #{self}:#{sym}" unless context.instance_eval(&onePre)
        end
      end

      resultado = original_method.bind(context.wrappedObject).call(*argumentos)

      self.class.invariants.each do |oneInvariant|
        raise "No se cumplio la invariante en #{context.wrappedObject}:#{sym}" unless context.wrappedObject.instance_exec(&oneInvariant)
      end

      argumentos_sym.each_with_index do |arg,index|
        context.define_singleton_method(arg) do
          argumentos[index]
        end
      end

      unless proc_after.empty?
        proc_after.each do |onePost|
          raise "Error de Post-Condicion en #{self}:#{sym}" unless context.instance_exec(resultado,&onePost)
        end
      end
      resultado


    end
    @before = []
    @after = []
    super # para que rubymine no se queje
  end

  def before_and_after_each_call(before = proc{},after = proc{})
    @before = before
    @after = after
  end

  def invariant(&block)
    contract_class
    @invariants ||= []
    @invariants << block
  end

  def pre(&pre_condicion)
    contract_class
    @before ||= []
    @before << pre_condicion
  end

  def post(&post_condicion)
    contract_class
    @after ||= []
    @after << post_condicion
  end

  def invariants
    @invariants ||= [proc { true }]
  end

  def before
    @before ||= [proc { true }]
  end

  def after
    @after ||= [proc { true }]
  end

  def decorated_methods
    @decored_methods ||={}
  end

  def add_decorated_method sym,method
    @decored_methods ||= {}
    @decored_methods[sym] = method
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

  def generate_context
    context = Wrapper.new self
    context
  end

  def contract_class
    return if has_contract

    @has_contract = true
  end

end

