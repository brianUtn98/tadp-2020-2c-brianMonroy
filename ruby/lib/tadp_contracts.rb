require_relative 'contract_framework'

# Para utilizar este framework, es necesario realizar un require sobre este archivo. Su modo de uso es a través de los mensajes
# invariant, pre y post
# invariant se encarga de mantener un objeto consistente, siendo una aserción que se debe cumplir para todas las instancias de una clase en cada momento.
# pre es un bloque que debe cumplirse antes de la ejecución de un método, debe colocarse arriba del método que se quiere afectar
# post es un bloque que debe cumplirse luego de la ejecución de un método, debe colocarse también arriba del método.
#
# El framework soporta la incorporación de varias invariantes sobre una clase, sin embargo solo se tomarán los últimos bloques pre/post para un método.
#
# Ejemplo de uso:
#
# class Operaciones
#   #precondición de dividir
#    pre { divisor != 0 }
#   #postcondición de dividir
#    post { |result| result * divisor == dividendo }
#    def dividir(dividendo, divisor)
#      dividendo / divisor
#    end
#
#
#   # este método no se ve afectado por ninguna pre/post condición
#    def restar(minuendo, sustraendo)
#      minuendo - sustraendo
#    end
#
# end
#
# class Guerrero
#   attr_accessor :vida
#   invariant {vida >= 0}
#
#   def initialize vida
#   @vida = vida
#   end
# end
#
# si hiciesemos Guerrero.new -2 debería lanzar un error ya que no se cumple la invariante vida >= 0.

class Class
  include BeforeAndAfter
end

