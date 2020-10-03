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

# Codigo de migue
# module BeforeAndAfter
#
#   def method_added(name)
#     @methods ||= []
#     return if @methods.include?(name)
#     @methods << name
#
#     meth = instance_method(name)
#
#     @before_hook ||= proc { |_meth_name, *_args| raise 'No hook defined!' }
#     @after_hook ||= proc { |_meth_name, *_args| raise 'No hook defined!' }
#
#     before_hook = @before_hook
#     after_hook = @after_hook
#
#     define_method(name) do |*args, &block|
#       before_hook.call(name, *args)
#
#       result = meth.bind(self).call(*args, &block)
#
#       after_hook.call(result)
#     end
#   end
#
#   def before(&blk)
#     @before_hook = blk
#   end
#
#   def after(&blk)
#     @after_hook = blk
#   end
#
#   def before_and_after_each_call(before=proc{}, after=proc{})
#     @before_hook = before
#     @after_hook = after
#   end
#
#   def pre(&before)
#     @before_hook = before
#   end
#
#   def post(&after)
#     @after_hook = after
#   end
# end

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
    post_blocks.push(post_block)
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
      raise Exception, "No se cumplieron las invariantes" unless contexto.instance_eval(&invariante)
    end
  end
end

# module BeforeAndAfterModule
#
#   def before_blocks
#     @before_blocks ||= []
#   end
#
#   def after_blocks
#     @after_blocks ||= []
#   end
#
#   def before_and_after_each_call(before,after)
#     self.before_blocks.push(before)
#     self.after_blocks.push(after)
#   end
#
# end

# module BeforeAndAfter
#   include InvariantModule
#   @before = nil
#   @after = nil
#   class << self
#     attr_accessor :before, :after
#   end
#
#   def before_and_after_each_call(before = proc {},after = proc {})
#     @before = before
#     @after = after
#   end
#
#   def method_added(sym)
#     return if @working
#
#     metodo_original = instance_method(method_name)
#
#     @working = true
#     proc_antes = @before
#     proc_despues = @after
#     define_method(sym) do
#       proc_antes.call
#       resultado = metodo_original.bind(self).call
#       resultado
#       self.class.send(:controlarInvariants,self)
#       proc_despues.call
#     end
#     @working = false
#   end
#
#   def pre(&before)
#     @before = proc {|contexto|
#                 unless contexto.instance_eval(&before)
#                   raise Error("No se cumplio la pre-condicion del metodo")
#                                end}
#   end
#
#   def post(&after)
#     @after = proc {|contexto|
#                unless contexto.instance_eval(&after)
#                  raise Error("No se cumplio la post-condicion del metodo")
#                               end}
#   end
#
# end

module Redefinicion
  include InvariantModule


  # def self.included base
  #   base.extend(InvariantModule)
  # end

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
  #include BeforeAndAfterModule

  protected def contexto_metodo (metodo,argumentos)
    Prototipo.new self
  end

  protected def ejecutar_pre(contexto)
    #return if before == nil
    before.call(contexto)
    #contexto.instance_eval(&before)
  end

  protected def ejecutar_post(contexto)
    #return if after == nil
    after.call(contexto)

  end



  @tarea_realizada = nil

  protected def redefinir_metodo sym
    getters = self.send(:getters)
    metodos_reservados = self.send(:metodos_reservados)
    return if @tarea_realizada == sym or self.is_a? Prototipo or (metodos_reservados + getters).include? sym

    self.redifinir_privado sym

  end

  protected def redifinir_privado sym
    return if @working

    @tarea_realizada = sym

    metodo_original = self.instance_method(sym)



    self.define_method(sym) do |*argumentos|

      @working = true
      contexto = contexto_metodo metodo_original,argumentos

      puts "Redefiniendo metodo #{sym} en #{self}"

      resultado = metodo_original.bind(contexto.contexto).call(*argumentos)

      self.class.send(:controlarInvariants, contexto.contexto)

      self.class.send(:ejecutar_pre,contexto.contexto)

      self.class.send(:ejecutar_post,contexto.contexto)

      resultado

      #self.class.send(:ejecutar_post,contexto.contexto)
      #self.class.after.call(contexto.contexto)
    end

    @working = false

    @tarea_realizada = nil
  end

  private def getters
    @getters ||= []
    @getters
  end

  private def agregar_getters(metodo)
    @getters = self.send(:getters) + metodo
  end

  private def metodos_reservados
    [:irb_binding]
  end

  def pre(&before)
    puts 'Definido un pre'
    @before = proc {|contexto| raise Exception, "No se cumplio la pre-condicion del metodo" unless contexto.instance_eval(&before)}
  end

  def post(&after)
    puts 'Definido un post'
    @after = proc{|contexto| raise Exception,"No se cumplio la post-condicion del metodo" unless contexto.instance_eval(&after)}
  end

  end



