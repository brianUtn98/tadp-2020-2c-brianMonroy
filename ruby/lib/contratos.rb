require 'rspec'


#CODIGO extraido de la clase 5.
class Prototipo
  attr_accessor :prototipo

  def initialize prototipo= Object.new
    self.prototipo = prototipo
  end

  def contexto
    self.prototipo
  end

  # def set_property(sym, value)
  #   unless self.prototype.respond_to? sym
  #     self.singleton_class.send :attr_accessor, sym
  #     self.send "#{sym}=", value
  #   end
  # end
  #
  # def set_method(sym, block)
  #   self.define_singleton_method sym, block
  # end
  #
  # def set_prototype(proto)
  #   self.prototype = proto
  # end
  #
  # def respond_to_missing?(sym, include_all = true)
  #   super(sym, include_all) or self.prototype.respond_to? sym
  # end
  #
  # def method_missing(sym, *args)
  #   super unless self.respond_to? sym
  #   # method = self.prototype.method(sym).unbind
  #   # method.bind(self).call *args
  #   self.prototype.send(sym, *args)
  # end
end

module Condiciones
  def pre_blocks
    @pre_blocks ||= []
    @pre_blocks
  end

  def post_blocks
    @post_blocks ||= []
    @post_blocks
  end

  def pre(&block)
    puts 'Agregado un pre'
    self
    pre_block = proc {raise Error("No se cumple la pre-condicion") unless self.instance_eval(block) }
    pre_blocks.push(pre_block)
  end

  def post(&block)
    puts 'Agregado un post'
    self
    post_block = proc {raise Error("No se cumple la post-condicion") unless self.instance_eval(block)}
    post_blocks.push(post_block
    )
  end
end

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
      raise Exception.new("No se cumplieron las invariantes") unless contexto.instance_eval(&invariante)
    end
  end
end

module BeforeAndAfterModule

  def before_blocks
    @before_blocks ||= []
  end

  def after_blocks
    @after_blocks ||= []
  end

  def before_and_after_each_call(before,after)
    self.before_blocks.push(before)
    self.after_blocks.push(after)
  end


end

module Redefinicion
  include InvariantModule
  include BeforeAndAfterModule
  include Condiciones
  protected def contexto_metodo (metodo,argumentos)
    Prototipo.new self
  end

  @tarea_realizada = nil

  protected def redefinir_metodo sym
    getters = self.send(:getters)
    metodos_reservados = self.send(:metodos_reservados)
    if @tarea_realizada == sym or self.is_a? Prototipo or (metodos_reservados + getters).include? sym
      return
    end
    self.redifinir_privado sym

  end

  protected def redifinir_privado sym
    @tarea_realizada = sym

    metodo_original = self.instance_method(sym)

    self.define_method(sym) do |*argumentos|

      contexto = contexto_metodo metodo_original,argumentos

      # agregar before

      puts "Redefiniendo metodo #{sym} en #{self}"

      resultado = metodo_original.bind(contexto.contexto).call(*argumentos)

      self.class.send(:controlarInvariants, contexto.contexto)

      # agregar after
      resultado
    end

    @tarea_realizada = nil
  end

  private def getters
    @getters ||= []
    @getters
  end

  private def agregar_getters(method_names)
    @getters = self.send(:getters) + method_names
  end

  private def metodos_reservados
    [:irb_binding]
  end
end



module Wrapper
  include Redefinicion
end



