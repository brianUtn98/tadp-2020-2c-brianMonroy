#require_relative 'contratos'
require_relative 'contratos.rb'

class Pila
  attr_accessor :current_node, :capacity

  invariant { capacity >= 0 }
  invariant { height <= capacity}

  post { empty? }
  def initialize(capacity)
    @capacity = capacity
    @current_node = nil
  end

  pre { !full? }
  #post { height > 0 }
  def push(element)
    @current_node = Node.new(element, current_node)
  end

  pre { !empty? }
  def pop
    element = top
    @current_node = @current_node.next_node
    element
  end

  pre { !empty? }
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


#
# def self.method_added(metodo_a_sobreescribir)
#   puts "Estoy agregando #{metodo_a_sobreescribir}"
#   # quiero sobreescribir el codigo de la funcion
#   metodo_a_sobreescribir.instance_eval do
#     # agrego la pre condicion al codigo
#     self.pre
#     super
#     # agrego la post condicion al codigo
#     self.post
#   end
