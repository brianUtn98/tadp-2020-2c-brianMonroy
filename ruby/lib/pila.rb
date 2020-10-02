require_relative 'contratos.rb'

class Object
  include Wrapper


  def self.attr_reader(*sym)
      send(:agregar_getters, sym)
      super
    end

  def self.attr_accessor(*sym)
      send(:agregar_getters, sym)
      super
    end


  def self.method_added(sym)
    return if @flag
    @flag = true
    redefinir_metodo sym
    @flag = false
  end
end


class Pila
  attr_accessor :current_node, :capacity

  invariant { capacity >= 0 }
  #invariant { capacity >= height }
  post { empty? }
  def initialize(capacity)
    @capacity = capacity
    @current_node = nil
  end

  pre { !full? }
  post { height.positive? }
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

class Guerrero

  attr_accessor :vida, :fuerza

  def initialize vida,fuerza
    @vida = vida
    @fuerza = fuerza
  end
  invariant { vida >= 0 }
  invariant { fuerza.positive? && fuerza < 100 }


  def atacar(otro)
    otro.vida -= fuerza
  end

  def bajar unidades
    self.vida -= unidades
  end

end

class Golondrina

  attr_reader :energia, :cansada
  invariant { energia >= 0}
  def initialize energia
    @energia = energia
    @cansada = false
  end

  pre { !cansada }
  post{ cansada }
  def volar kms
    @energia -= kms
    @cansada = true
  end

  def energia
    @energia
  end

  post{ !cansada }
  def cansada
    @cansada
  end

  post{ energia > 0 }
  def comer grs
    self.energia += grs * 10
    @cansada = false
  end

end


pila = Pila.new -2
pila.push 1

pila.push 1
pila.push 2
pila.push 3
#
# marine = Guerrero.new 100,50
# marine.bajar 101
#
# pepita = Golondrina.new 100
# pepita.volar 200

