require 'sourcify'
require_relative 'spec_helper'

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

  describe 'test individual' do

    it 'deberia poder hacer division entera' do
      expect{
        d = DuckedClass.new
        d.dividirEnteros 10,5
      }.to_not raise_error
    end

    it 'no deberia poder dividir con float' do
      expect{
        d = DuckedClass.new
        d.dividirEnteros 10,5.5
      }.to raise_error(RuntimeError)
    end

    it 'deberia poder meter elementos en una pila' do
      expect{ pila = Pila.new 2
      d = DuckedClass.new
      d.meterEnPila pila,5
      }.to_not raise_error
    end

    it 'no puedo usar meterPila con algo que no sea una pila' do
      expect{
        d = DuckedClass.new
        div = Operaciones.new
        d.meterEnPila div,5
      }.to raise_error(RuntimeError)
    end

    it 'no puedo meter en una pila algo que no sea entero' do
      expect{
        d = DuckedClass.new
        pila = Pila.new 2
        d.meterEnPila pila,5.5
      }.to raise_error(RuntimeError)
    end

    #combinacion de pre con ducked
    it 'deberia poder meter en una pila si habilito' do
      expect{
        m = MixedClass.new
        p = Pila.new 2
        m.habilitar
        m.meterEnPila p,6
      }.to_not raise_error
    end

    it 'no deberia poder meter en pila sin habilitar' do
      expect{
        m = MixedClass.new
        p = Pila.new 2
        m.meterEnPila p,6
      }.to raise_error(RuntimeError)
    end

    #m habria que habilitarlo, pero el orden de ejecución es primero duck y luego pre, así que no hace falta, falla por duck.
    it 'deberia fallar por ducked y no por pre' do
      expect{
        m = MixedClass.new
        m.meterEnPila 5,2
      }.to raise_error(RuntimeError)
    end

    it 'deberia fallar por ducked y no por pre, segundo param' do
      expect{
        m = MixedClass.new
        p = Pila.new 2
        m.meterEnPila p,5.5
      }.to raise_error(RuntimeError)
    end

    it 'deberia fallar por cantidad de parametros incorrecta' do
      expect{
        m = MixedClass.new
        m.metodo_que_falla 2,5
      }.to raise_error(RuntimeError)
    end

    it 'deberia fallar colateralmente' do
      expect{
        d = DuckedClass.new
        p = Pila.new 2
        d.meterEnPila p,5
        d.meterEnPila p,6
        d.meterEnPila p,7
      }.to raise_error(RuntimeError)
    end

    it 'deberia fallar si le paso otra cosa' do
      expect{
        m = MixedClass.new
        m.saludar 3,"Hola"
      }.to raise_error(RuntimeError)
    end

    it 'deberia andar si le paso bien' do
      expect{
        m = MixedClass.new
        m.saludar "Brian",21
      }

    end

    it 'deberia fallar con metodo encadenado' do
      expect{
        m = MixedClass.new
        g = Guerrero.new 50,10
        m.encadenado g
      }.to raise_error(RuntimeError)
    end

    it 'deberia andar con metodo encadenado' do
      expect{
        m = MixedClass.new
        p = Pila.new 2
        p.push 2
        m.encadenado p
      }.to_not raise_error
    end

    it 'deberia poder andar consigo mismo' do
      expect{
        m = MixedClass.new
        m.saludarse_a_si_mismo m
      }.to_not raise_error
    end

    it 'deberia andar con cualquier otra instancia' do
      expect{
        m1 = MixedClass.new
        m2 = MixedClass.new
        m1.saludarse_a_si_mismo m2
      }
    end

  end

end