require_relative 'tadp_contracts'

class Pila
  attr_accessor :current_node, :capacity
  invariant { capacity >= 0}

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

  invariant { vida >= 0 }
  invariant { fuerza.positive? && fuerza < 100 }

  def initialize vida,fuerza
    @vida = vida
    @fuerza = fuerza
  end



  def atacar(otro)
    otro.bajarVida @fuerza
  end

  def bajarVida cuanto
    @vida -= cuanto
  end

end

class Golondrina

  attr_accessor :energia, :cansada
  invariant { energia >= 0}
  def initialize energia
    @energia = energia
    @cansada = false
  end

  pre { no_cansada }
  post{ cansada? }
  def volar kms
    @energia -= kms
    @cansada = true
  end



  post{ energia > 0 }
  def comer grs
    self.energia += grs * 10
    @cansada = false
  end

  def no_cansada
    !cansada
  end

  def cansada?
    cansada == true
  end

end

class Operaciones
  #precondición de dividir
   pre { divisor != 0 }
  #postcondición de dividir
   post { |result| result * divisor == dividendo }
   def dividir(dividendo, divisor)
     dividendo / divisor
   end


  # este método no se ve afectado por ninguna pre/post condición
   def restar(minuendo, sustraendo)
     minuendo - sustraendo
   end

end

class TypedClass

  typed({nombre: String,edad:Integer},String)
  def cargarPersona(nombre,edad)
    if(edad < 18)
      mensaje = "Es menor"
      mensaje
    else
      mensaje = "Es mayor"
      mensaje
    end
  end
  typed({operacion: Operaciones,num1: Integer,num2: Integer},Integer)
  def dividir(operacion,num1,num2)
    resultado = operacion.dividir num1,num2
    resultado
  end
end