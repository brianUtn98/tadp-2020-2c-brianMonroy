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
    super unless wrappedObject.class.decorated_methods.has_key? symbol
      metodo = wrappedObject.class.decorated_methods[symbol].bind(wrappedObject)
      metodo.call(*args)
    end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?('user_') || super
  end
end

module BeforeAndAfter

  @before = nil
  @after = nil
  @ducked_array = nil

  attr_reader :before , :after,:invariants



  def method_added(sym)

    #retorno si es una clase del metamodelo, si el método ya fue decorado o si esta clase no tiene contratos.
    return if Class.ancestors.include? self or decorated_methods.has_key? sym or !@has_contract

    #puts "Dentro de method added self es #{self}, agregando metodo #{sym}"
    original_method = self.instance_method(sym)

    proc_before = before

    proc_after = after

    proc_ducked_array = @ducked_array

    argumentos_sym = original_method.parameters.map{|unArg| unArg[1].to_s}

    add_decorated_method(sym,original_method)
    define_method(sym) do |*argumentos|
      context = Wrapper.new self

      unless proc_ducked_array.nil?
        esperados = proc_ducked_array.size
        hallados = argumentos.size
        raise "Se esperaban #{esperados} parametros y se hallaron #{hallados}" unless esperados.eql? hallados
      end

      proc_ducked_array&.each_with_index do |metodos,index|
          raise "El parametro #{argumentos[index]} no entiende los mensajes #{metodos}" unless metodos.all? {|unMensaje| argumentos[index].respond_to? unMensaje}
        end
      
      argumentos_sym.each_with_index do |arg,index|
        context.define_singleton_method(arg) do
          argumentos[index]
        end
      end
      #puts "Dentro de define method self es una instancia de #{self.class}, defino metodo #{sym}"
      unless @before
        raise "Error de Pre-Condicion en #{self}:#{sym}" unless context.instance_eval(&proc_before)
      end

      resultado = original_method.bind(context.wrappedObject).call(*argumentos)

      self.class.invariants.each do |oneInvariant|
        #puts "Evaluando invariant sobre #{context.wrappedObject}"
        #puts "El wrapper es #{context}"
        raise "No se cumplio la invariante en #{context.wrappedObject}:#{sym}" unless context.wrappedObject.instance_exec(&oneInvariant)
      end

      argumentos_sym.each_with_index do |arg,index|
        context.define_singleton_method(arg) do
          argumentos[index]
        end
      end

      unless @after
        raise "Error de Post-Condicion en #{self}:#{sym}" unless context.instance_exec(resultado,&proc_after)
      end
      resultado


    end
    @before = nil
    @after = nil
    @ducked_array = nil
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
    @before = pre_condicion
  end

  def post(&post_condicion)
    contract_class
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
    #puts "Entre al metodo add_decorated_method para el metodo #{sym}"
    @decored_methods ||= {}
    @decored_methods[sym] = method
    #puts "Agregué el metodo #{sym} al hash"
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

  def generate_context
    context = Wrapper.new self
    context
  end

  def contract_class
    return if has_contract

    @has_contract = true
  end

  def duck *array
    contract_class
    @ducked_array = *array
  end

  def ducked_array
    @ducked_array ||= nil
  end

end

