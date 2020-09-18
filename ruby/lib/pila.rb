#require_relative 'contratos'
require 'rspec'

module Contrato
  def self.pre(&contenido)
    self.evaluar &contenido
  end

  def self.post(&contenido)
    self.evaluar &contenido
  end

  def self.invariant(&contenido)
    self.evaluar &contenido
  end

  def self.evaluar (&contenido)
    puts "evaluando"
    if(!contenido)
      self.fallar
    end
  end

  def fallar
    puts "Cagamos"
  end

end


class Pila
  include Contrato

  # alias_method :invariant, :invariante
  # alias_method :pre, :precondicion
  # alias_method :post, :postcondicion

  attr_accessor :current_node, :capacity



  # def invariant
  #   self.invariant
  # end
  #
  # def pre
  #   self.pre
  # end
  #
  # def post
  #   self.post
  # end
  Contrato.invariant { capacity >= 0 }

  Contrato.post { empty? }
  def initialize(capacity)
    @capacity = capacity
    @current_node = nil
  end

  Contrato.pre { !full? }
  Contrato.post { height.positive? }
  def push(element)
    @current_node = Node.new(element, current_node)
  end

  Contrato.pre { !empty? }
  def pop
    element = top
    @current_node = @current_node.next_node
    element
  end

  Contrato.pre { !empty? }
  def top
    current_node.element
  end

  def height
    empty? ? 0 : current_node.size
  end

  def empty?
    current_node.nil?
  end

  def full?
    height == capacity
  end

  Node = Struct.new(:element, :next_node) do
    def size
      next_node.nil? ? 1 : 1 + next_node.size
    end
  end
end
