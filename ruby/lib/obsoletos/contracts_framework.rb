require 'rspec'

# module Contrato
#   def self.included base
#     base.extend(BeforeAndAfterEachCall)
#   end
# end
# clase 5
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


module BeforeAndAfterEachCall
  @before = proc { true }
  @after = proc { true }

  @metodos_redefinidos ||= []
  # @working = false
  class << self
    attr_accessor :before, :after
  end

  def before_and_after_each_call(before = proc{},after = proc{})
    @before = before
    @after = after
  end

  def redefinir_metodo(sym)
    #puts "Redefiniendo metodo #{sym}"
    return if @working
    @working = true

    metodo_original = instance_method(sym)


    getters = self.send(:getters)
    metodos_reservados = self.send(:reserved_methods)

    if self.is_a? Prototipo or (metodos_reservados + getters).include? sym
      return
    end
    # if @before.nil?
    #   @before = proc {true}
    # end
    #
    # if @after.nil?
    #   @after = proc {true}
    # end

    proc_antes = @before
    proc_despues = @after

    self.define_method (sym) do |*arguments|
      #puts "Definiendo metodo #{sym} en #{contexto.contexto}"
      contexto = metod_context(metodo_original,arguments)
      # puts "Definiendo metodo #{sym} en #{contexto.contexto}"

      #if @before != nil
      #puts "llamando proc antes"
        proc_antes.call(contexto.contexto)
      #end


      resultado = metodo_original.bind(self).call(*arguments)
      #if @after != nil
      # puts "llamando proc despues"
        proc_despues.call(contexto.contexto)
        #end
      #puts "llamando resultado"
      resultado

      #@before = proc { true }
      #@after = proc { true }
      #puts "Termine de redefinir metodo #{sym} en #{contexto.contexto}"

      # @before = proc { 1 < 2}
      #@after = proc { 1 < 2}
    end

    @working = false




    #puts "Termine de redefinir metodo #{sym}"

  end

  def pre(&block)
    # @before = proc {raise Exception,"No se cumplio la pre-condicion del metodo" unless self.instance_eval(&block)}
    # puts "Definiendo un pre en #{self}"
    @before = proc { |contexto| raise Exception.new,"No se cumple pre-condition" unless contexto.instance_eval(&block) }
  end

  def post(&block)
    # puts "Definiendo un post en #{self}"
    # @after = proc {raise Exception,"No se cumplio la post-condicion del metodo" unless self.instance_eval(&block)}
    @after = proc { |contexto| raise Exception.new, "No se cumple post-condition" unless contexto.instance_eval(&block)}
  end

  def metod_context (metodo,argumentos)
    Prototipo.new self
  end

  private def getters
    @getters ||= []
    @getters
  end

  private def add_getters(method_names)
    @getters = self.send(:getters) + method_names
  end

  private def reserved_methods
    [:irb_binding]
  end
end

