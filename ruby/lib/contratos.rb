class PropertyNotFound < StandardError
end

module Magia
  # ¿Esto es un mixin?
  def self.method_added(name)
    puts "algo"
  end
  def before_and_after_each_call
    puts "Estoy en before and after metodo"
    # Bloque Before. Se ejecuta antes de cada mensaje
    proc{ puts "Hola Before" }
    # Bloques After. Se ejecuta después de cada mensaje
    proc{ puts "Hola After" }
  end
end

class Contrato
  include Magia
  attr_accessor :id
  def initialize
    @properties = {}
  end

  def set_property(property_name, valor)
    @properties[property_name] = valor
    define_singleton_method(property_name) do |*params|
      property = get_property(property_name)
      case property
      when Proc
        instance_exec(*params, &property)
      else
        property
      end
    end
  end

  def get_property(nombre_propiedad)
    @properties.fetch(nombre_propiedad) { raise PropertyNotFound.new }
  end

  #def method_missing(method_name, *params, &block)
  #if @properties.has_key?(method_name)
      #get_property(method_name)
      #else
      #super
      #  end
  #end
end

contrato1 = Contrato.new
contrato1.set_property(:id, 100)
contrato1.set_property(:nombre, 'Pepe')
contrato1.set_property(:saludar, proc do |nombre_saludador| "Hola #{nombre_saludador}, soy #{nombre}"end)
puts "#{contrato1.get_property(:id)}"
puts "#{contrato1.saludar("Sofia")}"
