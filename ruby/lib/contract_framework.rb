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
    # method_name.to_s.start_with?('user_') || super
    wrappedObject.respond_to_missing? method_name || super
  end
end

module BeforeAndAfter

  @before = nil
  @after = nil
  # @typed_args = nil
  #@typed_result = nil


  attr_reader :before , :after,:invariants,:typed,:typed_args,:typed_result



  def method_added(sym)

    #retorno si es una clase del metamodelo, si el método ya fue decorado o si esta clase no tiene contratos.
    return if Class.ancestors.include? self or decorated_methods.has_key? sym or !@has_contract

    #puts "Dentro de method added self es #{self}, agregando metodo #{sym}"
    original_method = self.instance_method(sym)

    proc_before = before

    proc_after = after

    proc_typed_args = typed_args

    proc_typed_result = typed_result

    argumentos_sym = original_method.parameters.map{|unArg| unArg[1].to_s}

    add_decorated_method(sym,original_method)
    define_method(sym) do |*argumentos|
      context = Wrapper.new self
      
      argumentos_sym.each_with_index do |arg,index|
        context.define_singleton_method(arg) do
          argumentos[index]
        end
      end

      unless @typed_args
        proc_typed_args.each_with_index do |key,index|
          raise "No se cumplio el tipo #{key[1].to_s} en el parametro #{key[0].to_s}" unless argumentos[index].is_a? proc_typed_args[key[0]]
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

      unless @typed_result
        puts "Evaluando typed_result en #{self}:#{sym}"
        raise "El resultado no es de tipo #{proc_typed_result.to_s}" unless resultado.is_a? proc_typed_result
      end
      resultado


    end
    @before = nil
    @after = nil
    @typed_result = nil
    @typed_args = nil

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

  def typed_args
    @typed_args ||= {a: Object}
  end

  def typed_result
    @typed_result ||= Object
  end

  def decorated_methods
    @decored_methods ||= {}
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

  def typed map,result
    contract_class
    puts "Definiendo typed con #{map}:#{result}"
    @typed_args = map
    @typed_result = result
    puts "#{typed_args}:#{typed_result}"
  end

end