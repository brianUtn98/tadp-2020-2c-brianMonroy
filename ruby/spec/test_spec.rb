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

describe 'test con la pila' do

  before do
    @pila = Pila.new (2)
    @pila.push 2
    @pila.push 3
  end

  it 'deberia tirar error de pre-condicion al hacer push' do
    sym = :push
    expect(@pila.push 4).to raise_error(PreConditionError.new(sym))

  end

  it 'deberia tirar error de invariant al crear una pila con capacidad negativa' do
    expect(@pila2 = Pila.new(-2)).to raise ( "No se cumplio la invariante")
  end

  before do
    @pila = Pila.new 1
    # pila vacia
  end

  it 'deberia tirar error de pre-condicion al pedirle top a una pila vacia' do
    expect(@pila.top).to raise ("No se cumplio la pre-condicion")
  end



end

describe 'test con el guerrero' do
  before do
    @atila = Guerrero.new 100,90
    @bleda = Guerrero.new 80,10
  end

  it 'deberia tirar error de invariante cuando atila ataque a bleda' do
    expect(@atila.atacar @bleda).to raise ("No se cumplio la invariante")
  end

  it 'bleda puede atacar a atila' do
    @bleda.atacar @atila
    expect(@bleda.vida).eql? 90
  end



end