require_relative 'contract_framework'


class Pila
  attr_accessor :current_node, :capacity

  #por algun motivo, se debe incluir el mixin luego de attr_accesor
  include Contrato


  invariant { capacity >= 0}

  post { empty? }
  def initialize(capacity)
    @capacity = capacity
    @current_node = nil
  end

  # def capacity
  #   @capacity
  # end

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
  include Contrato
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

  attr_accessor :energia, :cansada
  include Contrato
   invariant { energia >= 0}
  def initialize energia
    @energia = energia
    @cansada = false
  end

  pre { !cansada }
  post{ cansada }
  def volar kms
    self.energia -= kms
    self.cansada = true
  end
  #
  # def energia
  #   @energia
  # end



  post{ energia > 0 }
  def comer grs
    self.energia += grs * 10
    @cansada = false
  end

end