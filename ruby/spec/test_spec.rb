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

describe 'Contracts FW test' do

  describe 'invariants' do
  it 'deberia saltar violacion de invariant una pila con capacidad negativa' do
    expect{ pila=Pila.new -1 }.to raise_error(RuntimeError)
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
        invariant{ capacity < 50 }
      end
      pila.push 2
    }.to raise_error(RuntimeError)
  end

  it 'pepita no puede volar mas que su energia' do
    expect{
      pepita = Golondrina.new 100
      pepita.volar 150
    }.to raise_error(RuntimeError)
  end



end

  describe 'pre-condition' do
      it 'deberia fallar con argumentos' do
        expect{
          operacion = Operaciones.new
          operacion.dividir 30,0
        }.to raise_error(RuntimeError)
      end

    it 'no se puede agregar elementos a una pila llena' do
      expect{
        pila = Pila.new 1
        pila.push 2
        pila.push 3
      }.to raise_error(RuntimeError)
    end

    it 'no se puede sacar elementos de una pila vacia' do
      expect{
        pila = Pila.new 100
        pila.pop
      }.to raise_error(RuntimeError)
    end

    it 'pepita no puede volar si esta cansada' do
      expect{
        pepita = Golondrina.new 100
        pepita.volar 50
        pepita.volar 10
      }.to raise_error(RuntimeError)
    end

  end

  describe 'post-condition' do
    it 'deberia fallar post de dividir' do
      expect{
        div = Operaciones.new
        div.dividir 10,3
      }.to raise_error(RuntimeError)
    end
  end

  class A
    attr_accessor :unParam,:otroParam
    include Contrato
    def initialize unParam, otroParam
      @unParam = unParam
      @otroParam = otroParam
    end



    pre { unParam < 100 }
    def inc q
      @unParam += q
    end

    post { otroParam <unParam}
    def bleh
      @unParam += @otroParam
    end

  end

  describe('method_added') {

    it 'deberia incluir los metodos al hash' do
      expect(A.decorated_methods.has_key? :inc).to eq(true)
      expect(A.decorated_methods.has_key? :bleh).to eq(true)
      expect(A.decorated_methods.has_key? :incucai).to eq(false)
    end

  }

  describe 'Wrapper' do

    it 'deberia fallar al llamar al objeto original' do
      expect{
        pila = Pila.new 2
        wrapperPila = Wrapper.new pila
        wrapperPila.push 2
        wrapperPila.push 3
        pila.push 4
      }.to raise_error(RuntimeError)
    end

    it 'wrapper ignora condiciones' do
      expect{
        pila = Pila.new 1
        pila.push 2
        wrapperPila = Wrapper.new pila
        wrapperPila.push 4
      }.not_to raise_error
    end
  end

end