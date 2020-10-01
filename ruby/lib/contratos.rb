require 'rspec'

class Prototipada
  attr_accessor :prototipo

  def initialize prototipo = Object.new
    self.prototipo = prototipo
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
      raise Exception.new("No se cumplieron las invariantes") unless contexto.instance_exec(&invariante)
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

class Object
  include InvariantModule
  include BeforeAndAfterModule
  include Condiciones

  def self.method_added(sym)
    return if @tarea_realizada
    metodo_original = self.instance_method(sym)
    contexto = self
    puts ("Agregando metodo  #{sym} en #{self} ")
    @tarea_realizada = true
    self.define_method(sym) do |*argumentos|

      puts "Redefiniendo metodo #{sym} en #{self}"
      # contexto = self # aca me falta guardarme el contexto para bindear más tarde.
      self.class.send(:controlarInvariants, self)
      resultado = metodo_original.bind(self).call(*argumentos)
      resultado

    end
    #@tarea_realizada = false


  end
end
