require 'sourcify'
require_relative 'spec_helper'

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

  it 'deberia saltar violacion de invariant una pila con capacidad negativa' do
    expect{pila=Pila.new -1}.to raise_error(RuntimeError)
  end

  it 'deberia soltar una excepcion de invariant un guerrero atacando a otro más debil' do
    expect{
      unGuerrero = Guerrero.new 100,90
      otroGuerrero = Guerrero.new 10 , 10
      unGuerrero.atacar otroGuerrero
    }.to raise_error(RuntimeError)
  end

  it 'deberia soltar una excepcion de invariant un guerrero con fuerza > 100' do
    expect{
      unGuerrero = Guerrero.new 100,120
    }.to raise_error(RuntimeError)
  end

  it 'deberia soltar una excepcion de invariant un guerrero con vida negativa' do
    expect{
      unGuerrero = Guerrero.new(-100,20)
    }.to raise_error(RuntimeError)
  end

  it 'deberia soltar una excepcion, luego de abrir la clase y agregar una invariant' do
    expect{
      pila = Pila.new 100
      class Pila
        invariant{capacity < 50}
      end
      pila.push 2
    }.to raise_error(RuntimeError)
  end



end