require 'rspec'
require_relative '../lib/main'


### Errores para Copiar en los spec
#
# Invariant:
# No se cumplio la invariante
#
# Pre:
# No se cumplio la pre-condicion
#
# Post:
# No se cumplio la post-condicion

describe 'un test' do

  before do
    @pila = Pila.new (2)
    @pila.push 2
    @pila.push 3
  end

  it 'deberia tirar error de pre-condicion al hacer push' do

    expect(@pila.push 4).to raise_error("No se cumplio la pre-condicion")

  end

  it 'deberia tirar error de invariant al crear una pila con capacidad negativa' do
    expect(@pila2 = Pila.new(-2)).to raise_error( "No se cumplio la invariante")
  end

end