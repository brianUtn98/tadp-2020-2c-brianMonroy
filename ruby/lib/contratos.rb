require 'rspec'

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

  def controlarInvariants(contexto)
    invariantes.each do |invariante|
      raise Exception("No se cumplieron las invariantes") unless contexto.instance_eval(&invariante)
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
  end

  def post(&block)
    puts 'Agregado un post'
  end
end

class Object
  include InvariantModule
  include BeforeAndAfterModule
  include Condiciones
end
