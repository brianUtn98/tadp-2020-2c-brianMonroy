require_relative 'obsoletos/framework'


class Object
  include BeforeAndAfterEachCall
  #include Contrato

  # def self.attr_reader(*sym)
  #   send(:agregar_getters, sym)
  #   super
  # end
  #
  # def self.attr_accessor(*sym)
  #   send(:agregar_getters, sym)
  #   super
  # end

  def self.method_added(sym)
    #puts "Agregando metodo #{sym}"
    redefinir_metodo(sym)
    #puts "Termine de agregar metodo #{sym}"
  end
end
#
#
class A
  attr_accessor :numero

  # include Contrato
  before_and_after_each_call(proc {puts 'Before'},proc{puts 'After'})
  #pre {numero > 0}
  #post {numero > 0}
  # def initialize numero
  #   @numero = numero
  #   puts 'Inicio'
  # end

  #pre {numero > 0}
  #post {numero > 0}
  def saludar nombre
    puts "Hola #{nombre}"
  end

  #pre {numero > 0}
  #post {numero > 0}
  def despedir nombre
    puts "Chau #{nombre}"
  end

  pre { numero > 0 }
  #post { numero > 1}
  def restar
    @numero -= 1
  end

  # def numero
  #   @numero
  # end
end
#
# class Pila
#   #before_and_after_each_call(proc {puts 'Before'},proc{puts 'After'})
#
#   attr_accessor :current_node, :capacity
#
#   #invariant { capacity >= 0 }
#
#
#   # pre {true}
#   pre { true }
#   post { empty? }
#   def initialize(capacity)
#     @capacity = capacity
#     @current_node = nil
#   end
#
#
#
#
#   pre { !full? }
#   post { height.positive? }
#   def push(element)
#     @current_node = Node.new(element, current_node)
#   end
#
#   pre { !empty? }
#   #post {true}
#   def pop
#     element = top
#     @current_node = @current_node.next_node
#     element
#   end
#
#   pre { !empty? }
#   # post {true}
#   def top
#     current_node.element
#   end
#
#   def height
#     empty? ? 0 : current_node.size
#   end
#
#   def empty?
#     current_node.nil?
#   end
#
#   def full?
#     height == capacity
#   end
#
#   Node = Struct.new(:element, :next_node) do
#     def size
#       next_node.nil? ? 1 : 1 + next_node.size
#     end
#   end
# end

a = A.new
a.saludar "brian"
a.saludar "juan"
a.restar

#a.restar
# #
#  pila = Pila.new 2
#  pila.push 2
#  pila.push 3
#  pila.push 3
#
